import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_para_admin/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart' show DateFormat, toBeginningOfSentenceCase;
import '../../utils/colors.dart';
import 'driver_details_screen.dart';

class NewDriversPage extends StatefulWidget {
  const NewDriversPage({super.key});

  @override
  State<NewDriversPage> createState() => _NewDriversPageState();
}

class _NewDriversPageState extends State<NewDriversPage> {
  String filter = '';
  final messageController = TextEditingController();
  String verificationFilter = 'all'; // 'all', 'verified', 'unverified'

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 50,
                width: 275,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(100)),
                child: TextFormField(
                  controller: messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      color: grey,
                    ),
                    suffixIcon: filter != ''
                        ? IconButton(
                            onPressed: (() {
                              setState(() {
                                filter = '';
                                messageController.clear();
                              });
                            }),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: grey,
                            ),
                          )
                        : const Icon(
                            Icons.account_circle_outlined,
                            color: grey,
                          ),
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(width: 1, color: grey),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(width: 1, color: Colors.black),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    hintText: 'Search Driver',
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      filter = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Verification Filter Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFilterButton('All', 'all'),
              const SizedBox(width: 10),
              _buildFilterButton('Verified', 'verified'),
              const SizedBox(width: 10),
              _buildFilterButton('Unverified', 'unverified'),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          TextBold(
              text: 'Drivers Management', fontSize: 18, color: Colors.black),
          const SizedBox(
            height: 5,
          ),
          StreamBuilder<QuerySnapshot>(
              stream: _getDriversStream(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return const Center(child: Text('Error'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Colors.black,
                    )),
                  );
                }

                final data = snapshot.requireData;

                // Filter drivers based on verification status
                List<DocumentSnapshot> filteredDocs = data.docs.where((doc) {
                  final driverData = doc.data() as Map<String, dynamic>?;
                  if (driverData == null) return false;

                  final isVerified = driverData['isVerified'] ?? false;

                  if (verificationFilter == 'verified') {
                    return isVerified;
                  } else if (verificationFilter == 'unverified') {
                    return !isVerified;
                  } else {
                    return true; // 'all' filter
                  }
                }).toList();

                return Expanded(
                  child: SizedBox(
                    child: ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final driverData =
                            filteredDocs[index].data() as Map<String, dynamic>?;

                        // Handle case where driver data might be null
                        if (driverData == null) {
                          return const SizedBox.shrink();
                        }

                        final isVerified = driverData['isVerified'] ?? false;

                        return Padding(
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          child: Card(
                            elevation: 3,
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DriverDetailsScreen(
                                      driverData: filteredDocs[index],
                                      driverId: filteredDocs[index].id,
                                    ),
                                  ),
                                );
                              },
                              leading: CircleAvatar(
                                minRadius: 20,
                                maxRadius: 20,
                                backgroundImage: NetworkImage(driverData[
                                        'profilePicture'] ??
                                    'https://cdn-icons-png.flaticon.com/256/149/149071.png'),
                              ),
                              title: TextBold(
                                  text: driverData['name'] ?? 'Unknown',
                                  fontSize: 15,
                                  color: Colors.black),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextRegular(
                                      text: '${driverData['vehicle'] ?? ''}'
                                              ' - ' +
                                          (driverData['plateNumber'] ?? ''),
                                      fontSize: 11,
                                      color: Colors.grey),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      TextRegular(
                                          text: 'Status: ',
                                          fontSize: 11,
                                          color: Colors.grey),
                                      TextBold(
                                          text: driverData['isActive'] ?? false
                                              ? 'Active'
                                              : 'Inactive',
                                          fontSize: 11,
                                          color: driverData['isActive'] ?? false
                                              ? Colors.green
                                              : Colors.red),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      TextRegular(
                                          text: 'Verification: ',
                                          fontSize: 11,
                                          color: Colors.grey),
                                      TextBold(
                                          text: isVerified
                                              ? 'Verified'
                                              : 'Not Verified',
                                          fontSize: 11,
                                          color: isVerified
                                              ? Colors.green
                                              : Colors.orange),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('Bookings')
                                          .where('driverId',
                                              isEqualTo: filteredDocs[index].id)
                                          .snapshots(),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<QuerySnapshot>
                                              snapshot) {
                                        if (snapshot.hasError) {
                                          print(snapshot.error);
                                          return const Center(
                                              child: Text('Error'));
                                        }
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return TextRegular(
                                              text: 'Loading bookings...',
                                              fontSize: 11,
                                              color: Colors.grey);
                                        }

                                        final bookingsData =
                                            snapshot.requireData;

                                        return TextBold(
                                            text:
                                                '${bookingsData.docs.length} Bookings',
                                            fontSize: 11,
                                            color: Colors.blue);
                                      }),
                                ],
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Row(
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        var text =
                                            'tel:${driverData['number'] ?? ''}';
                                        if (await canLaunch(text)) {
                                          await launch(text);
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.phone,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title:
                                                  const Text('Delete Driver'),
                                              content: Text(
                                                  'Are you sure you want to delete ${driverData['name'] ?? 'this driver'}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    // Delete the driver from Firestore
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('Drivers')
                                                        .doc(filteredDocs[index]
                                                            .id)
                                                        .delete();

                                                    // Show success message
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            '${driverData['name'] ?? 'Driver'} has been deleted'),
                                                        backgroundColor:
                                                            Colors.green,
                                                      ),
                                                    );

                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String value) {
    final isSelected = verificationFilter == value;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          verificationFilter = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? blue : Colors.white,
        foregroundColor: isSelected ? Colors.black : grey,
        side: BorderSide(
          color: isSelected ? blue : grey,
          width: 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: TextRegular(
        text: label,
        fontSize: 12,
        color: isSelected ? Colors.black : grey,
      ),
    );
  }

  Stream<QuerySnapshot> _getDriversStream() {
    Query query = FirebaseFirestore.instance.collection('Drivers');

    // Apply name search filter if exists
    if (filter.isNotEmpty) {
      query = query
          .where('name',
              isGreaterThanOrEqualTo: toBeginningOfSentenceCase(filter))
          .where('name', isLessThan: '${toBeginningOfSentenceCase(filter)}z');
    }

    return query.snapshots();
  }
}
