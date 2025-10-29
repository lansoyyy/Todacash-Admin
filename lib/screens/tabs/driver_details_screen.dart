import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_para_admin/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/colors.dart';

class DriverDetailsScreen extends StatefulWidget {
  final DocumentSnapshot driverData;
  final String driverId;

  const DriverDetailsScreen({
    super.key,
    required this.driverData,
    required this.driverId,
  });

  @override
  State<DriverDetailsScreen> createState() => _DriverDetailsScreenState();
}

class _DriverDetailsScreenState extends State<DriverDetailsScreen> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: TextBold(
          text: 'Driver Details',
          fontSize: 18,
          color: Colors.black,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final data = widget.driverData.data() as Map<String, dynamic>;
              var text = 'tel:${data['number']}';
              if (await canLaunch(text)) {
                await launch(text);
              }
            },
            icon: const Icon(
              Icons.phone,
              color: Colors.blue,
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Drivers')
            .doc(widget.driverId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading driver data'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(data['profilePicture']),
                        ),
                        const SizedBox(height: 15),
                        TextBold(
                          text: data['name'] ?? 'N/A',
                          fontSize: 24,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: data['isActive'] ?? false
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextBold(
                                text: data['isActive'] ?? false
                                    ? 'Active'
                                    : 'Inactive',
                                fontSize: 12,
                                color: data['isActive'] ?? false
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: data['isVerified'] ?? false
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextBold(
                                text: data['isVerified'] ?? false
                                    ? 'Verified'
                                    : 'Not Verified',
                                fontSize: 12,
                                color: data['isVerified'] ?? false
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Verification Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextBold(
                              text: 'Verification Status',
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            Switch(
                              value: data['isVerified'] ?? false,
                              onChanged: (value) async {
                                setState(() {
                                  isLoading = true;
                                });

                                await FirebaseFirestore.instance
                                    .collection('Drivers')
                                    .doc(widget.driverId)
                                    .update({'isVerified': value});

                                setState(() {
                                  isLoading = false;
                                });
                              },
                              activeColor: Colors.green,
                              inactiveThumbColor: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Personal Information
                  _buildSectionTitle('Personal Information'),
                  _buildInfoCard('Email', data['email'] ?? 'N/A'),
                  _buildInfoCard('Phone Number', data['number'] ?? 'N/A'),
                  _buildInfoCard('Address', data['address'] ?? 'N/A'),
                  const SizedBox(height: 20),

                  // Vehicle Information
                  _buildSectionTitle('Vehicle Information'),
                  _buildInfoCard('Vehicle Type', data['vehicle'] ?? 'N/A'),
                  _buildInfoCard('Plate Number', data['plateNumber'] ?? 'N/A'),
                  const SizedBox(height: 20),

                  // License Information
                  _buildSectionTitle('License Information'),
                  if (data['licenseImageUrl'] != null &&
                      data['licenseImageUrl'].toString().isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextBold(
                            text: 'Driver License',
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              data['licenseImageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.withOpacity(0.2),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LicenseImageViewer(
                                      imageUrl: data['licenseImageUrl'],
                                      driverName: data['name'] ?? 'Driver',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('View Full Screen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildInfoCard('License', 'No license image uploaded'),
                  const SizedBox(height: 20),

                  // Performance Information
                  _buildSectionTitle('Performance Information'),
                  _buildInfoCard('Stars', '${data['stars'] ?? 0}'),
                  _buildInfoCard(
                      'Total Bookings', '${data['history']?.length ?? 0}'),
                  _buildInfoCard('Delivery History',
                      '${data['deliveryHistory']?.length ?? 0}'),
                  const SizedBox(height: 20),

                  // Location Information
                  _buildSectionTitle('Location Information'),
                  _buildInfoCard(
                      'Latitude', '${data['location']?['lat'] ?? 0.00}'),
                  _buildInfoCard(
                      'Longitude', '${data['location']?['long'] ?? 0.00}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextBold(
        text: title,
        fontSize: 18,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: TextRegular(
              text: '$label:',
              fontSize: 14,
              color: grey,
            ),
          ),
          Expanded(
            child: TextBold(
              text: value,
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class LicenseImageViewer extends StatelessWidget {
  final String imageUrl;
  final String driverName;

  const LicenseImageViewer({
    super.key,
    required this.imageUrl,
    required this.driverName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextBold(
          text: '$driverName - License',
          fontSize: 16,
          color: Colors.white,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: 100,
                      color: Colors.white,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Failed to load image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
