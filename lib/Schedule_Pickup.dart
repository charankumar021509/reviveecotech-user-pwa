import 'package:flutter/material.dart';
import 'package:revive_eco_tech_app/Add_Address.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For formatting the currency
import 'manage_addresses.dart';

// ==== Constants ====
const kPrimaryColor = Color(0xFF013D5A);
const kCreamColor = Color(0xFFFCF3E3);
const kAccentColor = Color(0xFFA6CB4E);

// ==== NEW: Data Model for Selected Item ====
class SelectedScrapItem {
  // ... (SelectedScrapItem class remains unchanged) ...
  final String categoryId;
  final String categoryName;
  final String itemId;
  final String itemName;
  double amount; // Can be weight (kg) or count (pieces)
  final String unit;
  final double pricePerUnit;
  double calculatedCost;

  SelectedScrapItem({
    required this.categoryId,
    required this.categoryName,
    required this.itemId,
    required this.itemName,
    required this.amount,
    required this.unit,
    required this.pricePerUnit,
  }) : calculatedCost = amount * pricePerUnit;

  // Method to update amount and recalculate cost
  void updateAmount(double newAmount) {
    amount = newAmount;
    calculatedCost = amount * pricePerUnit;
  }

  // Helper for display
  String get displayAmount {
    return (unit == 'kg') ? amount.toStringAsFixed(1) : amount.round().toString();
  }

  // ✅ NEW: Helper to convert back to Map for saving
  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'itemId': itemId,
      'itemName': itemName,
      'amount': amount,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'calculatedCost': calculatedCost,
    };
  }
}

class SchedulePickup extends StatefulWidget {
  final String? pickupId;
  // ✅ 1. ADDED new properties for tab navigation
  final VoidCallback? onPickupScheduled;
  final bool isTab;

  const SchedulePickup({
    super.key,
    this.pickupId,
    this.onPickupScheduled, // Callback for success
    this.isTab = false, // Default to false (for "pushed" routes)
  });

  @override
  State<SchedulePickup> createState() => _SchedulePickupState();
}

TextEditingController dateController = TextEditingController();

class _SchedulePickupState extends State<SchedulePickup> {
  final TextEditingController _descriptionController = TextEditingController();

  // Address State
  List<DocumentSnapshot> _addresses = [];
  DocumentSnapshot? _selectedAddress;
  String? _selectedTimeSlot;

  // Loading States
  bool _isLoadingAddresses = true;
  bool _isLoadingPrices = true;
  bool _isSubmitting = false;

  // State Variables for Edit Mode
  bool _isLoadingPickupData = false;
  bool _isEditMode = false;

  Map<String, Map<String, dynamic>> _availableCategories = {};
  List<SelectedScrapItem> _selectedItems = [];

  // Totals
  double _totalEstimatedCost = 0.0;
  double _totalEstimatedWeight = 0.0;

  void showCustomPopup(BuildContext context) {
    // ... (showCustomPopup implementation - no changes) ...
    showDialog(
      context: context,
      builder: (context) {
        int? selectedIndex;
        List<String> slots = [
          '09:00AM - 11:00AM',
          '11:00AM - 01:00PM',
          '03:00PM - 05:00PM',
          '05:00PM - 07:00PM',
        ];

        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add time slot',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ...List.generate(slots.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIndex = index;
                          });
                          Navigator.of(context).pop();
                          _onTimeSlotSelected(slots[index]);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? kAccentColor
                                : Colors.transparent,
                            border: Border.all(width: 1, color: Colors.black54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                slots[index],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onTimeSlotSelected(String slot) {
    setState(() {
      _selectedTimeSlot = slot;
    });
  }

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.pickupId != null;
    _fetchAddresses();
    _fetchPriceList().then((_) {
      if (_isEditMode && widget.pickupId != null) {
        _loadPickupData(widget.pickupId!);
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchAddresses() async {
    // ... (_fetchAddresses implementation - no changes) ...
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoadingAddresses = false);
      return;
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .orderBy('createdAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _addresses = querySnapshot.docs;
          _isLoadingAddresses = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAddresses = false);
        _showSnackBar("Failed to load addresses: $e", isError: true);
      }
    }
  }

  Future<void> _fetchPriceList() async {
    // ... (_fetchPriceList implementation - no changes) ...
    if (mounted) setState(() => _isLoadingPrices = true);
    Map<String, Map<String, dynamic>> tempCategories = {};

    try {
      // 1. Get all categories
      final categorySnapshot = await FirebaseFirestore.instance
          .collection('price_list')
          .orderBy('order')
          .get();

      // 2. For each category, get its items
      for (var categoryDoc in categorySnapshot.docs) {
        final categoryData = categoryDoc.data();
        final categoryId = categoryDoc.id;
        final categoryName = categoryData['name'] as String? ?? 'Unnamed Category';
        List<Map<String, dynamic>> itemsList = [];

        final itemsSnapshot = await categoryDoc.reference
            .collection('items')
            .orderBy('order')
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          final itemData = itemDoc.data();
          itemsList.add({
            'id': itemDoc.id, // Store item ID
            'name': itemData['name'] ?? 'Unnamed Item',
            'price': (itemData['price'] as num?)?.toDouble() ?? 0.0,
            'unit': itemData['unit'] ?? 'unit',
          });
        }

        // Store category info and its items
        tempCategories[categoryId] = {
          'name': categoryName,
          'items': itemsList,
        };
      }

      if (mounted) {
        setState(() {
          _availableCategories = tempCategories;
          _isLoadingPrices = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPrices = false);
        _showSnackBar("Failed to load scrap prices: $e", isError: true);
        print("Error fetching price list: $e");
      }
    }
  }

  Future<void> _loadPickupData(String pickupId) async {
    // ... (_loadPickupData implementation - no changes) ...
    if (!mounted) return;
    setState(() => _isLoadingPickupData = true);

    try {
      final pickupDoc = await FirebaseFirestore.instance.collection('pickups').doc(pickupId).get();

      if (!pickupDoc.exists || !mounted) {
        _showSnackBar("Pickup data not found.", isError: true);
        Navigator.pop(context); // Go back if data isn't found
        return;
      }

      final data = pickupDoc.data() as Map<String, dynamic>;

      DocumentSnapshot? matchingAddress;
      try {
        matchingAddress = _addresses.firstWhere(
              (addrDoc) => addrDoc.id == data['addressId'],
        );
      } catch (e) {
        print("Warning: Saved address ID ${data['addressId']} not found in current user's address list.");
        matchingAddress = null;
      }
      _selectedAddress = matchingAddress;


      // Pre-fill Date
      final pickupDate = (data['pickupDate'] as Timestamp?)?.toDate();
      if (pickupDate != null) {
        dateController.text = pickupDate.toLocal().toString().split(" ")[0];
      } else {
        dateController.clear();
      }

      // Pre-fill Time Slot
      _selectedTimeSlot = data['pickupTimeSlot'] as String?;

      // Pre-fill Description
      _descriptionController.text = data['description'] ?? '';

      // Rebuild the _selectedItems list
      final List<dynamic> itemsFromDb = data['scrapItems'] ?? [];
      _selectedItems = itemsFromDb.whereType<Map<String, dynamic>>().map((itemMap) {
        return SelectedScrapItem(
          categoryId: itemMap['categoryId'] ?? '',
          categoryName: itemMap['categoryName'] ?? '',
          itemId: itemMap['itemId'] ?? '',
          itemName: itemMap['itemName'] ?? 'Unknown Item',
          amount: (itemMap['amount'] as num?)?.toDouble() ?? 0.0,
          unit: itemMap['unit'] ?? 'unit',
          pricePerUnit: (itemMap['pricePerUnit'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      _updateTotals();

    } catch (e) {
      _showSnackBar("Error loading pickup data: $e", isError: true);
      print("Load Error: $e");
      if (mounted) Navigator.pop(context); // Go back on error
    } finally {
      if (mounted) setState(() => _isLoadingPickupData = false);
    }
  }

  void _updateTotals() {
    // ... (_updateTotals implementation - no changes) ...
    double newCost = 0.0;
    double newWeight = 0.0;

    for (var item in _selectedItems) {
      newCost += item.calculatedCost;
      if (item.unit.toLowerCase() == 'kg') {
        newWeight += item.amount;
      }
    }

    setState(() {
      _totalEstimatedCost = newCost;
      _totalEstimatedWeight = newWeight;
    });
  }

  void _showItemSelectionPopup(BuildContext context, String categoryId) {
    // ... (_showItemSelectionPopup implementation - no changes) ...
    final categoryData = _availableCategories[categoryId];
    if (categoryData == null || (categoryData['items'] as List).isEmpty) return;

    final String categoryName = categoryData['name'];
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(categoryData['items']);

    Map<String, dynamic>? selectedSubItem = items.isNotEmpty ? items[0] : null;
    SelectedScrapItem? existingCartItem;
    if (selectedSubItem != null) {
      existingCartItem = _selectedItems.firstWhere(
              (item) => item.itemId == selectedSubItem!['id'],
          orElse: () => SelectedScrapItem(categoryId: '', categoryName: '', itemId: '', itemName: '', amount: 0, unit: '', pricePerUnit: 0) // Dummy item if not found
      );
    }
    double localAmount = existingCartItem?.amount ?? 0.0;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final String unit = selectedSubItem?['unit'] ?? 'kg';
            final double maxSliderValue = (unit.toLowerCase() == 'kg') ? 200.0 : 50.0;
            final int divisions = (unit.toLowerCase() == 'kg') ? 400 : 50;

            return Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add item for $categoryName',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                    ),
                  ),
                  SizedBox(height: 20),

                  // --- Sub-item Dropdown ---
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: selectedSubItem,
                    items: items.map((item) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: item,
                        child: Text("${item['name']} (₹${item['price']}/${item['unit']})"),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        setModalState(() {
                          selectedSubItem = newValue;
                          existingCartItem = _selectedItems.firstWhere(
                                  (item) => item.itemId == selectedSubItem!['id'],
                              orElse: () => SelectedScrapItem(categoryId: '', categoryName: '', itemId: '', itemName: '', amount: 0, unit: '', pricePerUnit: 0) // Dummy item
                          );
                          localAmount = existingCartItem?.amount ?? 0.0;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Item Type',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  SizedBox(height: 20),

                  // --- Amount Slider ---
                  if (selectedSubItem != null) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Estimated Amount:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          (unit.toLowerCase() == 'kg')
                              ? '${localAmount.toStringAsFixed(1)} $unit'
                              : '${localAmount.round()} $unit',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: localAmount,
                      min: 0,
                      max: maxSliderValue,
                      divisions: divisions,
                      label: (unit.toLowerCase() == 'kg')
                          ? localAmount.toStringAsFixed(1)
                          : localAmount.round().toString(),
                      activeColor: kPrimaryColor,
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (double value) {
                        setModalState(() {
                          if (unit.toLowerCase() == 'kg') {
                            localAmount = value;
                          } else {
                            localAmount = value.roundToDouble();
                          }
                        });
                      },
                    ),
                  ],
                  SizedBox(height: 20),

                  // --- Add/Update Button ---
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: kPrimaryColor,
                      minimumSize: Size(double.infinity, 50),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: selectedSubItem == null ? null : () {
                      final itemToAddOrUpdate = selectedSubItem!;
                      final String itemId = itemToAddOrUpdate['id'];
                      final String itemName = itemToAddOrUpdate['name'];
                      final double itemPrice = itemToAddOrUpdate['price'];
                      final String itemUnit = itemToAddOrUpdate['unit'];

                      setState(() { // Update the main page state
                        int existingIndex = _selectedItems.indexWhere((item) => item.itemId == itemId);

                        if (existingIndex != -1) {
                          if (localAmount > 0) {
                            _selectedItems[existingIndex].updateAmount(localAmount);
                          } else {
                            _selectedItems.removeAt(existingIndex);
                          }
                        } else if (localAmount > 0) {
                          _selectedItems.add(SelectedScrapItem(
                            categoryId: categoryId,
                            categoryName: categoryName,
                            itemId: itemId,
                            itemName: itemName,
                            amount: localAmount,
                            unit: itemUnit,
                            pricePerUnit: itemPrice,
                          ));
                        }
                      });

                      _updateTotals(); // Recalculate totals
                      Navigator.pop(context); // Close the popup
                    },
                    child: Text( existingCartItem != null && existingCartItem!.amount > 0 ? 'Update Amount' : 'Add Item'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : kAccentColor,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitPickup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) { _showSnackBar("You must be logged in.", isError: true); return; }
    if (!_isEditMode && _selectedAddress == null) { _showSnackBar("Please select a pickup address.", isError: true); return; }
    if (dateController.text.isEmpty) { _showSnackBar("Please select a pickup date.", isError: true); return; }
    if (_selectedTimeSlot == null) { _showSnackBar("Please select a time slot.", isError: true); return; }
    if (_selectedItems.isEmpty) { _showSnackBar("Please add at least one scrap item.", isError: true); return; }

    setState(() => _isSubmitting = true);

    try {
      List<Map<String, dynamic>> itemsForFirestore = _selectedItems.map((item) => item.toMap()).toList();
      List<String> categoryNamesInvolved = _selectedItems.map((item) => item.categoryName).toSet().toList();

      if (_isEditMode) {
        // --- UPDATE Existing Pickup ---
        final pickupRef = FirebaseFirestore.instance.collection('pickups').doc(widget.pickupId!);
        final updateData = {
          'scrapItems': itemsForFirestore,
          'scrapCategories': categoryNamesInvolved,
          'totalEstimatedWeight_kg': _totalEstimatedWeight,
          'estimatedCost': _totalEstimatedCost,
          'description': _descriptionController.text.trim(),
        };

        await pickupRef.update(updateData);
        _showSnackBar("Pickup updated successfully!");

      } else {
        // --- ADD New Pickup ---
        final pickupDate = DateTime.parse(dateController.text);
        final addressData = _selectedAddress!.data() as Map<String, dynamic>;

        await FirebaseFirestore.instance.collection('pickups').add({
          'userId': user.uid,
          'addressId': _selectedAddress!.id,
          'addressDetails': addressData,
          'pickupDate': Timestamp.fromDate(pickupDate),
          'pickupTimeSlot': _selectedTimeSlot,
          'scrapItems': itemsForFirestore,
          'scrapCategories': categoryNamesInvolved,
          'totalEstimatedWeight_kg': _totalEstimatedWeight,
          'estimatedCost': _totalEstimatedCost,
          'description': _descriptionController.text.trim(),
          'status': 'Pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _showSnackBar("Pickup scheduled successfully!");
      }

      // ✅ 2. MODIFIED Success Navigation
      if (mounted) {
        if (widget.isTab) {
          // If we are in a tab, call the callback to switch pages
          widget.onPickupScheduled?.call();
          // Also, clear the form for the next use
          _clearForm();
        } else {
          // If we were "pushed" (e.g., Edit), just pop the page
          Navigator.pop(context);
        }
      }

    } catch (e) {
      _showSnackBar("Failed to ${_isEditMode ? 'update' : 'schedule'} pickup: $e", isError: true);
      print("Submit Error: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ✅ 3. ADDED clear form helper
  void _clearForm() {
    setState(() {
      _descriptionController.clear();
      _selectedAddress = null;
      _selectedTimeSlot = null;
      dateController.clear();
      _selectedItems.clear();
      _updateTotals(); // Resets totals to 0
    });
  }


  Widget _buildSection(
      {required IconData icon,
        required String title,
        required Widget child}) {
    // ... (_buildSection implementation - no changes) ...
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Row(
                  children: [
                    Icon(icon, color: kPrimaryColor),
                    SizedBox(width: 10),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateAndRefresh(BuildContext context) async {
    // ... (_navigateAndRefresh implementation - no changes) ...
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ManageAddressesPage()),
    );
    setState(() {
      _selectedAddress = null;
      _isLoadingAddresses = true;
    });
    _fetchAddresses();
  }

  Future<void> _selectDate() async {
    // ... (_selectDate implementation - no changes) ...
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: kPrimaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        dateController.text = pickedDate.toLocal().toString().split(" ")[0];
      });
    }
  }

  // ✅ 4. EXTRACTED AppBar
  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        _isEditMode ? 'Edit Pickup' : 'Schedule Pickup',
        style: TextStyle(
          fontFamily: 'RedHatDisplay',
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.0,
          color: kCreamColor,
        ),
      ),
      backgroundColor: kPrimaryColor,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  // ✅ 5. EXTRACTED Body
  Widget _buildBody() {
    final currencyFormatter = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final List<String> categoryIds = _availableCategories.keys.toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          // ==== Pickup Location Section ====
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Section Header ---
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                          child: Row(
                            children: [
                              Icon(Icons.location_on, color: kPrimaryColor),
                              SizedBox(width: 10),
                              Text(
                                "Pickup Location",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // --- Dropdown Field ---
                        AbsorbPointer(
                          absorbing: _isEditMode,
                          child: Opacity(
                            opacity: _isEditMode ? 0.6 : 1.0,
                            child: _isLoadingAddresses
                                ? Center(child: CircularProgressIndicator())
                                : _addresses.isEmpty
                                ? Container(
                              /*... No addresses found ...*/
                            ) // Handle this case
                                : DropdownButtonFormField<DocumentSnapshot>(
                              value: _selectedAddress,
                              isExpanded: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 10),
                                hintText: 'Select Address',
                                helperText: _isEditMode
                                    ? 'Address cannot be changed during edit'
                                    : null,
                                helperStyle: _isEditMode
                                    ? TextStyle(color: Colors.grey.shade600)
                                    : null,
                              ),
                              items: _addresses.map((doc) {
                                final data =
                                doc.data() as Map<String, dynamic>;
                                return DropdownMenuItem<DocumentSnapshot>(
                                  value: doc,
                                  child: Text(
                                    '${data['addressType']}: ${data['line1']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedAddress = value;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        // --- Buttons Row (Add and Manage) ---
                        if (!_isEditMode)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddAddress(),
                                    ),
                                  );
                                  setState(() {
                                    _selectedAddress = null;
                                    _isLoadingAddresses = true;
                                  });
                                  _fetchAddresses();
                                },
                                child: Text(
                                  '+ Add New Address',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _navigateAndRefresh(context);
                                },
                                child: Text(
                                  'Manage Addresses',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // --- Positioned Clear Button ---
                    if (!_isEditMode)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedAddress != null) {
                              setState(() {
                                _selectedAddress = null;
                              });
                            }
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _selectedAddress != null
                                  ? Colors.red.shade700
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // ==== Date & Time Section ====
          _buildSection(
            icon: Icons.calendar_month,
            title: "Date & Time",
            child: AbsorbPointer(
              absorbing: _isEditMode,
              child: Opacity(
                opacity: _isEditMode ? 0.6 : 1.0,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: dateController,
                        decoration: InputDecoration(
                          labelText: "Select Date",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                          helperText: _isEditMode
                              ? 'Date cannot be changed during edit'
                              : null,
                          helperStyle: _isEditMode
                              ? TextStyle(color: Colors.grey.shade600)
                              : null,
                        ),
                        readOnly: true,
                        onTap: _isEditMode ? null : _selectDate,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        controller: TextEditingController(text: _selectedTimeSlot),
                        decoration: InputDecoration(
                          labelText: "Select Time",
                          hintText: "Time Slot",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time_filled),
                          helperText: _isEditMode
                              ? 'Time cannot be changed during edit'
                              : null,
                          helperStyle: _isEditMode
                              ? TextStyle(color: Colors.grey.shade600)
                              : null,
                        ),
                        onTap: _isEditMode ? null : () => showCustomPopup(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==== Add Scrap Items Section ====
          _buildSection(
            icon: Icons.recycling,
            title: _isEditMode ? "Edit Scrap Items" : "Add Scrap Items",
            child: _isLoadingPrices
                ? Center(child: CircularProgressIndicator())
                : _availableCategories.isEmpty
                ? Text("No scrap types found in database.")
                : Wrap(
              spacing: 10,
              runSpacing: 5,
              children: categoryIds.map((categoryId) {
                final categoryName =
                    _availableCategories[categoryId]?['name'] ??
                        'Unknown';
                bool categoryHasSelection = _selectedItems.any(
                        (item) => item.categoryId == categoryId);

                return ChoiceChip(
                  label: Text(categoryName),
                  labelStyle: TextStyle(
                    color: categoryHasSelection
                        ? Colors.white
                        : Colors.black,
                    fontWeight: categoryHasSelection
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  selected: categoryHasSelection,
                  selectedColor: kPrimaryColor,
                  backgroundColor: Colors.grey.shade200,
                  onSelected: (bool _) {
                    _showItemSelectionPopup(context, categoryId);
                  },
                );
              }).toList(),
            ),
          ),

          // ==== Pickup Summary Section ====
          _buildSection(
            icon: Icons.receipt_long,
            title: "Pickup Summary",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Address ---
                if (_selectedAddress != null) ...[
                  Text("Address:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(_selectedAddress!.data() as Map<String, dynamic>)['line1'] ?? ''}',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          '${(_selectedAddress!.data() as Map<String, dynamic>)['fullAddress'] ?? ''}',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                // --- Date & Time ---
                if (dateController.text.isNotEmpty ||
                    _selectedTimeSlot != null) ...[
                  Text("Date & Time:",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  if (dateController.text.isNotEmpty)
                    Text('Date: ${dateController.text}',
                        style: TextStyle(fontSize: 14)),
                  if (_selectedTimeSlot != null)
                    Text('Slot: $_selectedTimeSlot',
                        style: TextStyle(fontSize: 14)),
                  SizedBox(height: 10),
                ],

                // --- Items Header ---
                Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
                if (_selectedItems.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No items added yet. Tap a category above to add items.',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  )
                else

                // --- Items List ---
                  ..._selectedItems.map((item) {
                    return Container(
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Item Name (Expanded)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0),
                              child: Text(
                                '${item.categoryName} - ${item.itemName} (${item.displayAmount} ${item.unit})',
                                style: TextStyle(fontSize: 14, height: 1.3),
                              ),
                            ),
                          ),

                          // Group Price and Delete Button
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Item Cost
                              Padding(
                                padding: const EdgeInsets.only(top: 0),
                                child: Text(
                                    currencyFormatter.format(item.calculatedCost),
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        height: 1.3)),
                              ),

                              // Delete Button
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedItems.removeWhere(
                                            (i) => i.itemId == item.itemId);
                                  });
                                  _updateTotals();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.close,
                                    color: Colors.red.shade700,
                                    size: 20,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                // --- Divider and Totals ---
                if (_selectedItems.isNotEmpty) ...[
                  Divider(height: 20, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Estimated Weight (kg):',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      Text('${_totalEstimatedWeight.toStringAsFixed(1)} kg',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Estimated Value:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        currencyFormatter.format(_totalEstimatedCost),
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ==== Description Section ====
          _buildSection(
            icon: Icons.description,
            title: "Add/Edit Description (Optional)",
            child: TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'e.g., "Mainly cardboard boxes and plastic bottles"',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),

          // ==== Submit Button ====
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isSubmitting ? null : _submitPickup,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: kAccentColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSubmitting
                      ? CircularProgressIndicator(
                    valueColor:
                    AlwaysStoppedAnimation<Color>(kPrimaryColor),
                  )
                      : Text(
                    _isEditMode ? 'Update Pickup' : 'Submit Pickup',
                    style: TextStyle(
                      fontFamily: 'RedHatDisplay',
                      fontWeight: FontWeight.bold,
                      color: kPrimaryColor,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 40)
        ],
      ),
    );
  }

  // ✅ 6. MODIFIED MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    // Show loading UI based on edit mode
    if (_isLoadingPickupData) {
      if (widget.isTab) {
        // Tab loading state
        return const Center(child: CircularProgressIndicator(color: kPrimaryColor));
      } else {
        // Pushed page loading state
        return Scaffold(
          backgroundColor: kCreamColor,
          appBar: _buildAppBar(),
          body: const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
        );
      }
    }

    // Build the main body content once
    final bodyContent = _buildBody();

    if (widget.isTab) {
      // If in a tab, return just the body
      return bodyContent;
    } else {
      // If pushed, return a full Scaffold
      return Scaffold(
        backgroundColor: kCreamColor,
        appBar: _buildAppBar(),
        body: bodyContent,
      );
    }
  }
}