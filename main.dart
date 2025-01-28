import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Dispositivos',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController modelController = TextEditingController(); // Nuevo controlador para el modelo
  String selectedDeviceType = 'Impresora';
  String selectedBrand = 'HP';
  String selectedLocation = 'BZME - Zumpango';

  final List<String> deviceTypes = [
    'Impresora',
    'Computadora',
  ];

  final List<String> brands = ['HP', 'Panasonic', 'Steren', 'CDP', 'Samsung', 'Dell', 'Apple', 'Cisco', 'Panasonic', 'Zebra', 'Epson', 'Brother', 'Sharp', 'Meraki', 'HoneyWell', 'ViewSonic', 'APC', 'CDP', 'LG', 'Pioneer', 'RCA', 'Daewoo', 'Sansui', 'Hikvision', 'Epcom'];
  final List<String> locations = [
    'COQR - Constituyentes',
    'CRME - Cuautitlan Romero Rubio',
    'LETO - Lerma',
    'LGME - Lago de Guadalupe',
  ];

  final DatabaseReference _deviceRef = FirebaseDatabase.instance.ref().child('devices');

  void registerDevice() async {
    // Normalizamos el número de serie: eliminamos espacios y lo convertimos a mayúsculas
    String serialNumber = textController.text.trim().toUpperCase().replaceAll(" ", "");

    if (serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un número de serie')),
      );
      return;
    }

    // Verificar si el número de serie ya está registrado
    final existingDeviceSnapshot = await _deviceRef
        .orderByChild('serialNumber')
        .equalTo(serialNumber)
        .get();

    if (existingDeviceSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este número de serie ya está registrado')),
      );
      return;
    }

    // Obtener el timestamp
    int timestamp = DateTime.now().millisecondsSinceEpoch;

    // Registrar el nuevo dispositivo en la base de datos
    await _deviceRef.push().set({
      'serialNumber': serialNumber.toUpperCase().replaceAll((" "), ("")), // Número de serie ya normalizado
      'deviceType': selectedDeviceType,
      'brand': selectedBrand,
      'location': selectedLocation,
      'model': modelController.text.trim(), // Nuevo campo para el modelo
      'registrationDate': timestamp, // Enviar el timestamp
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Dispositivo registrado: $selectedDeviceType ($serialNumber)')),
    );

    textController.clear();
    modelController.clear(); // Limpiar el campo del modelo
  }

  void scanCode() async {
    String scannedData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarcodeScanner(
          onScan: (String code) {
            setState(() {
              textController.text = code;
            });
          },
        ),
      ),
    ) ?? '';
    
    if (scannedData.isNotEmpty) {
      setState(() {
        textController.text = scannedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Dispositivos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Número de Serie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: modelController, // Campo de modelo
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true, // Agregado para evitar el overflow
                value: selectedDeviceType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Dispositivo',
                  border: OutlineInputBorder(),
                ),
                items: deviceTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDeviceType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true, // Agregado para evitar el overflow
                value: selectedBrand,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  border: OutlineInputBorder(),
                ),
                items: brands.map((String brand) {
                  return DropdownMenuItem<String>(
                    value: brand,
                    child: Text(brand),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBrand = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                isExpanded: true, // Agregado para evitar el overflow
                value: selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
                items: locations.map((String location) {
                  return DropdownMenuItem<String>(
                    value: location,
                    child: Text(location),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedLocation = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: registerDevice,
                child: const Text('Registrar Dispositivo'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: scanCode,
                child: const Text('Escanear Codigo'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: navigateToDevicesPage,
                child: const Text('Ver Todos los Dispositivos'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void navigateToDevicesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DevicesPage(),
      ),
    );
  }
}

class DevicesPage extends StatefulWidget {
  const DevicesPage({super.key});

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}
class _DevicesPageState extends State<DevicesPage> {
  final DatabaseReference _deviceRef = FirebaseDatabase.instance.ref().child('devices');
  String selectedDeviceType = 'Todos';
  String selectedBrand = 'Todos';
  String selectedLocation = 'Todos';

  final List<String> deviceTypes = [
    'Todos', 'Impresora', 'Computadora', 'Laptop', 'Router', 'Switch', 'Access Point', 'Checador de Personal', 'DVR', 'No Break'
  ];

  final List<String> brands = ['Todos', 'HP', 'Samsung'];

  final List<String> locations = [
    'Todos', 'ACME - Av. Central', 'AMGT - Cedis Celaya', 'ANQR - Antea', 'ATTO - Atlacomulco', 'AVME - Altavista', 
    'BAME - Acolman', 'BHQR - Hogar Bernardo Quintana', 'BIME - Ixtapaluca', 'BJSL - Benito Juarez', 'BQQR - Bernardo Quintana', 
    'BTME - Ozumbilla', 'BXME - Texcoco', 'BZME - Zumpango', 'CAME - Camarones', 'CDME - Vallejo-Los Reyes', 'CDQR - CEDIS Queretaro', 
    'CDSL - CEDIS San Luis Potosi', 'CDZA - Cedis Zacatecas', 'CFQR - 05 de Febrero', 'CHME - Chimalhuacan', 'CHSL - Chapultepec', 
    'CIGT - Cibeles', 'CIME - Chimalhuacan 2', 'COQR - Constituyentes', 'CRME - Cuautitlan Romero Rubio', 'CTGT - Celaya Tecnologico', 
    'CUME - Cuautitlan Izcalli', 'DBME - Beistegui-Tienda', 'DCME - Churubusco', 'DOGT - Dolores Hidalgo, Guanajuato', 
    'DTME - Tripoli', 'DUME - Uxmal', 'ECME - Echegaray', 'EMME - Ecatepec de Morelos', 'EOME - Ermita Oriente', 'ESPE - Especificaciones',
    'INME - Insurgentes', 'IRGT - Irapuato', 'LETO - Lerma', 'LGME - Lago de Guadalupe', 'LRME - Los Reyes', 'MIME - Manacar', 
    'MRME - Miramontes', 'MTTO - Metepec', 'MZME - Mazaryk', 'NZME - Neza', 'OAME - Tecamac', 'OBME - Observatorio', 'OCME - Coacalco', 
    'OEME - Ermita', 'OHME - Chalco', 'OJME - Jilotepec', 'OLME - Vista Hermosa', 'OMME - Amecameca', 'OTME - Tultitlan', 
    'OXME - Texcoco 2', 'PAQR - Pasteur', 'PAZA - Plaza Auskara', 'PCZA - Plaza Colon', 'PIME - Picacho', 'PMZA - Paseo del Mineral', 
    'PSME - Periferico Sur', 'PTTO - Tolotzin', 'RAME - La Raza', 'SAGT - San Miguel de Allende', 'SAME - Satelite -Tienda', 
    'SMGT - Salamanca', 'SPGT - San Luis de la Paz', 'SPSL - San Pedro S.L.P.', 'SRQR - San Juan del Rio', 'TCME - Tecamachalco', 
    'TCQR - Tienda CEDIS Queretaro', 'TEME - Tepotzotlan', 'TLME - Tlahuac', 'TZME - Tezontle', 'VDME - Valle Dorado', 'VHME - Via Morelos', 
    'VIME - La Villa', 'VJME - Vallejo', 'XOME - Xochimilco', 'ZAME - Zaragoza', 'ZCTO - Zitacuaro Bodega', 'ZITO - Zinacantepec', 
    'ZTTO - Zitacuaro'
  ];



  // Función para formatear el timestamp a la fecha y hora deseada
  String formatDate(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd/MM/yy (hh:mm a)').format(dateTime);}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispositivos Registrados'),
      ),
       body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedDeviceType,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Tipo de Dispositivo',
                    border: OutlineInputBorder(),
                  ),
                  items: deviceTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDeviceType = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Marca',
                    border: OutlineInputBorder(),
                  ),
                  items: brands.map((String brand) {
                    return DropdownMenuItem<String>(
                      value: brand,
                      child: Text(brand),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedBrand = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: selectedLocation,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por Ubicación',
                    border: OutlineInputBorder(),
                  ),
                  items: locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedLocation = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
              ],
            ),
          ),
                Expanded(
            child: StreamBuilder(
              stream: _deviceRef.onValue,  // Conexión a la base de datos
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar los dispositivos.'));
                }

                final devicesMap = snapshot.data!.snapshot.value as Map?;
                if (devicesMap == null || devicesMap.isEmpty) {
                  return const Center(child: Text('No hay dispositivos registrados.'));
                }

                final devices = devicesMap.values.toList();

                final filteredDevices = devices.where((device) {
                  bool matchesType = selectedDeviceType == 'Todos' || device['deviceType'] == selectedDeviceType;
                  bool matchesBrand = selectedBrand == 'Todos' || device['brand'] == selectedBrand;
                  bool matchesLocation = selectedLocation == 'Todos' || device['location'] == selectedLocation;
                  return matchesType && matchesBrand && matchesLocation;
                }).toList();

                return ListView.builder(
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final device = filteredDevices[index] as Map;
                    int timestamp = device['registrationDate']; // Obtén el timestamp
                    String formattedDate = formatDate(timestamp); // Formatea la fecha

                    return ListTile(
                      title: Text(device['deviceType']),
                      subtitle: Text(
                        'Núm. Serie: ${device['serialNumber']} \nMarca: ${device['brand']} \nUbicación: ${device['location']} \nFecha de Registro: $formattedDate',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}



class BarcodeScanner extends StatelessWidget {
  final Function(String) onScan;

  const BarcodeScanner({Key? key, required this.onScan}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanea un Código de Barras')),
      body: MobileScanner(
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              final String code = barcode.rawValue!;
              onScan(code);

              // Esperar un poco antes de navegar
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop(); // Volver a la pantalla anterior
                }
              });

              break;
            }
          }
        },
      ),
    );
  }
}
