class ApiEndPoints {
  static const String baseUrl =
      'http://192.168.0.7/metrecicla_api_v2/controllers/';
  static EndPoints endpoints = EndPoints();
}

class EndPoints {
  final String loginService = 'empleados.php';
  final String getEmployeesService = 'empleados.php';
  final String getchatarrasService = 'chatarras.php';
  final String editChatarrasService = 'chatarras.php';
  final String addChatarrasService = 'chatarras.php';
  final String deleteChatarrasService = 'chatarras.php';
  final String getProveedoresService = 'proveedores.php';
  final String addProveedoresService = 'proveedores.php';
  final String editProveedoresService = 'proveedores.php';
  final String deleteProveedoresService = 'proveedores.php';
}
