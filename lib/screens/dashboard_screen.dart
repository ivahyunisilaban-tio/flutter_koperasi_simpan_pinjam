import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    final username =
        auth.username ?? auth.role ?? "User";

    final isMobile =
        MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,

        title: const Text(
          'Dashboard',
          style: TextStyle(
            color: Colors.black,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(
                context,
                '/login',
              );
            },

            icon: const Icon(Icons.logout),
          )
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // HEADER
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4CAF50),
                      Color(0xFF2E7D32),
                    ],

                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),

                child: Row(
                  children: [

                    // FOTO PROFILE
                    Container(
                      padding: const EdgeInsets.all(3),

                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(0.3),

                        shape: BoxShape.circle,
                      ),

                      child: const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,

                        child: Icon(
                          Icons.person,
                          color: Colors.green,
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    // TEXT
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          const Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            username,

                            overflow:
                                TextOverflow.ellipsis,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // TITLE MENU
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                ),

                child: Row(
                  children: const [
                    Text(
                      'Menu Utama',

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // GRID MENU
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: GridView.count(
                  shrinkWrap: true,

                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount:
                      isMobile ? 2 : 3,

                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,

                  childAspectRatio:
                      isMobile ? 0.95 : 1.1,

                  children: [

                    buildMenu(
                      'Pengajuan',
                      Icons.person_add,
                      Colors.orange,
                      context,
                      '/pengajuan',
                    ),

                    buildMenu(
                      'Riwayat Kredit',
                      Icons.history,
                      Colors.green,
                      context,
                      '/riwayat',
                    ),

                    buildMenu(
                      'Saldo Kas',
                      Icons.account_balance,
                      Colors.blue,
                      context,
                      '/saldo',
                    ),

                    buildMenu(
                      'Rekapan',
                      Icons.receipt_long,
                      Colors.purple,
                      context,
                      '/rekapan',
                    ),

                    buildMenu(
                      'Laporan',
                      Icons.bar_chart,
                      Colors.red,
                      context,
                      '/laporan',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildInfoCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Container(
    padding: const EdgeInsets.all(15),

    decoration: BoxDecoration(
      color: Colors.white,

      borderRadius: BorderRadius.circular(15),

      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 5,
          offset: Offset(2, 2),
        )
      ],
    ),

    child: Row(
      children: [

        // ICON
        Container(
          padding: const EdgeInsets.all(10),

          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),

          child: Icon(
            icon,
            color: color,
          ),
        ),

        const SizedBox(width: 10),

        // TEXT
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                title,

                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget buildMenu(
  String title,
  IconData icon,
  Color color,
  BuildContext context,
  String route,
) {
  return Material(
    color: Colors.transparent,

    elevation: 2,
    shadowColor: Colors.black12,

    borderRadius: BorderRadius.circular(18),

    child: InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        Navigator.pushNamed(context, route);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(18),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 3),
            )
          ],
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            // ICON
            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                color: color,
                size: 26,
              ),
            ),

            const SizedBox(height: 14),

            // TITLE
            Text(
              title,

              textAlign: TextAlign.center,

              maxLines: 2,

              overflow: TextOverflow.ellipsis,

              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}