import 'package:admin_monitoreo/screens/user_location_screen.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class UserListScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Usuarios"),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: apiService.fetchUsers(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                var user = snapshot.data?[index];
                return Card(
                  color: const Color.fromARGB(255, 81, 200, 252), // Color celeste claro
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user['Nombres'] ?? 'Nombre no disponible',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255)
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'ID: ${user['idusuario']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.map, color: Colors.white),
                          onPressed: () {
                            // Aquí puedes agregar la lógica para mostrar la ubicación del usuario
                            // Por ejemplo, abrir un nuevo diálogo o pantalla con la ubicación
                            showUserLocation(context, user['idusuario']);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error al cargar usuarios"));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
void showUserLocation(BuildContext context, int userId) async {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserLocationScreen(userId: userId),
    ),
  );
}


}
