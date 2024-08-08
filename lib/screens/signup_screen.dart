import 'dart:convert'; // JSON 데이터를 인코딩/디코딩하기 위한 패키지
import 'dart:io'; // 파일 작업을 위한 패키지
import 'package:flutter/material.dart'; // Flutter에서 UI를 구성하기 위한 패키지
import 'package:image_picker/image_picker.dart'; // 이미지를 선택할 수 있게 해주는 패키지
import 'package:image/image.dart' as img; // image 패키지의 네임스페이스 지정
import 'package:http/http.dart' as http; // HTTP 요청을 보내기 위한 패키지
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage에 이미지를 업로드하기 위한 패키지
import '../providers/constants.dart'; // 프로젝트에서 사용하는 상수를 관리하는 파일

// 회원가입 페이지 클래스
class SignupScreen extends StatefulWidget {
  static const routeName = '/signup';

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

// 실제 상태를 관리하는 클래스
class _SignupScreenState extends State<SignupScreen> {
  // 입력을 받기 위한 TextEditingController들을 생성
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  File? _selectedImage; // 사용자가 선택한 이미지를 저장할 변수
  String _passwordError = ''; // 비밀번호 오류 메시지를 저장할 변수

  @override
  void initState() {//위젯 생성,초기화 관리 함수
    super.initState();
    _confirmPasswordController.addListener(_validatePassword); // 비밀번호 확인 필드에 변화가 있을 때마다 비밀번호를 검증
  }

  @override

  // 비밀번호와 비밀번호 확인 필드의 값이 일치하는지 확인하는 함수
  void _validatePassword() {
    setState(() {//상태업데이트 함수
      if (_passwordController.text != _confirmPasswordController.text) {
        _passwordError = '비밀번호가 일치하지 않습니다.'; // 비밀번호가 일치하지 않으면 오류 메시지를 설정
      } else {
        _passwordError = ''; // 비밀번호가 일치하면 오류 메시지 삭제
      }
    });
  }

  // 회원가입 버튼을 눌렀을 때 호출되는 함수
  Future<void> _signup(BuildContext context) async {
    final id = _idController.text; // 아이디 필드의 값을 가져옵니다.
    final password = _passwordController.text; // 비밀번호 필드의 값을 가져옵니다.
    final confirmPassword = _confirmPasswordController.text; // 비밀번호 확인 필드의 값을 가져옵니다.
    final nickname = _nicknameController.text; // 닉네임 필드의 값을 가져옵니다.
    final email = _emailController.text; // 이메일 필드의 값을 가져옵니다.
    final location = _locationController.text; // 거주지역 필드의 값을 가져옵니다.
    final age = int.tryParse(_ageController.text); // 나이 필드의 값을 정수로 변환하여 가져옵니다.

    if (id.isEmpty || password.isEmpty || nickname.isEmpty) {
      // 필수 필드가 비어 있을 경우, 오류 출력
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('입력 오류'),
            content: const Text('아이디, 비밀번호, 닉네임은 필수 입력 항목입니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // 회원가입 요청을 중단
    }

    // 비밀번호와 비밀번호 확인 필드가 일치하지 않는지 확인
    if (password != confirmPassword) {
      // 비밀번호가 일치하지 않을 경우, 오류 표시
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('입력 오류'),
            content: const Text('비밀번호가 일치하지 않습니다.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return; // 회원가입 요청을 중단
    }

    // 사용자가 이미지를 선택했는지 확인
    String? imageUrl;
    if (_selectedImage != null) {
      imageUrl = await _uploadImageToFirebase(_selectedImage!); // 이미지를 Firebase에 업로드하고 URL을 가져옵니다.
    }

    final url = Uri.parse('$baseUrl/users'); // 회원가입 요청을 보낼 서버의 URL을 설정합니다.

    // HTTP POST 요청을 위한 MultipartRequest 객체를 생성합니다.
    var request = http.MultipartRequest('POST', url)
      ..fields['user'] = json.encode({
        'username': id, // 사용자 아이디
        'password': password, // 비밀번호
        'nickname': nickname, // 닉네임
        'email': email, // 이메일
        'location': location, // 거주지역
        'age': age, // 나이
        'profileImage': imageUrl, // 프로필 이미지 URL
      });

    final response = await request.send(); // 서버에 회원가입 요청을 보냅니다.
    Navigator.of(context).pop(); // 요청이 끝나면 현재 페이지를 닫습니다.

    if (response.statusCode == 201) {
      // 요청이 성공하면 성공 메시지를 출력하고, 로그인 페이지로 이동하는 다이얼로그를 표시합니다.
      print('회원가입 성공!');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('회원가입 완료'),
            content: const Text('회원가입이 완료되었습니다! 로그인해주세요.'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/login'); // 로그인 페이지로 이동
                },
              ),
            ],
          );
        },
      );
    } else {
      // 요청이 실패하면 오류 메시지를 출력합니다.
      final responseBody = await response.stream.bytesToString();
      print('회원가입 실패');
      print('Response status: ${response.statusCode}');
      print('Response body: $responseBody');
    }
  }


  // 이미지 최적화 함수
  Future<File> _optimizeImage(File imageFile) async {
    // 이미지를 읽어들임
    final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) {
      throw Exception("이미지 디코딩에 실패했습니다.");
    }

    // 이미지 크기를 조정할 수 있습니다 (예: 가로 800px, 세로는 비율에 맞춰 자동 조정)
    final resizedImage = img.copyResize(image, width: 300);

    // 이미지를 jpg 포맷으로 변환하고 압축 (품질을 85%로 설정)
    final compressedImageBytes = img.encodeJpg(resizedImage, quality: 70);

    // 임시 파일로 저장
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(compressedImageBytes);

    return tempFile;
  }

  // 이미지를 Firebase Storage에 업로드하는 메서드입니다.
  Future<String?> _uploadImageToFirebase(File image) async {
    try {
      // 이미지를 최적화합니다.
      final optimizedImage = await _optimizeImage(image);

      final storageRef = FirebaseStorage.instance.ref(); // Firebase Storage의 참조를 가져옵니다.
      final imageRef = storageRef.child('profile_images/${optimizedImage.path.split('/').last}'); // 업로드할 이미지의 경로를 설정합니다.
      await imageRef.putFile(optimizedImage); // 최적화된 이미지를 업로드합니다.
      final imageUrl = await imageRef.getDownloadURL(); // 업로드된 이미지의 URL을 가져옵니다.
      return imageUrl; // 이미지 URL을 반환합니다.
    } catch (e) {
      // 업로드 중 오류가 발생하면 오류 메시지를 출력합니다.
      print('이미지 업로드 실패: $e');
      return null; // 업로드 실패 시 null을 반환합니다.
    }
  }

  // 갤러리에서 이미지를 선택하는 메서드입니다.
  Future<void> _pickImage() async {
    final picker = ImagePicker(); // ImagePicker 객체를 생성합니다.
    final pickedFile = await picker.pickImage(source: ImageSource.gallery); // 갤러리에서 이미지를 선택합니다.

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path); // 선택된 이미지를 _selectedImage에 저장합니다.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'), // 앱바의 제목을 설정합니다.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // 페이지 전체에 16픽셀의 패딩을 적용합니다.
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage, // 이미지를 선택하는 메서드를 호출합니다.
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!) // 이미지를 선택한 경우 해당 이미지를 보여줍니다.
                      : null,
                  child: _selectedImage == null
                      ? const Icon(
                    Icons.add_a_photo,
                    size: 40, // 이미지를 선택하지 않은 경우 아이콘을 보여줍니다.
                  )
                      : null,
                ),
              ),
              TextField(
                controller: _idController, // 아이디 입력 필드
                decoration: const InputDecoration(labelText: '아이디 *'),
              ),
              TextField(
                controller: _passwordController, // 비밀번호 입력 필드
                decoration: const InputDecoration(
                  labelText: '비밀번호 *',
                ),
                obscureText: true, // 비밀번호를 숨겨서 입력합니다.
              ),
              TextField(
                controller: _confirmPasswordController, // 비밀번호 확인 입력 필드
                decoration: InputDecoration(
                  labelText: '비밀번호 확인 *',
                  errorText: _passwordError.isEmpty ? null : _passwordError, // 비밀번호 검증 오류 메시지를 표시합니다.
                ),
                obscureText: true, // 비밀번호를 숨겨서 입력합니다.
              ),
              TextField(
                controller: _nicknameController, // 닉네임 입력 필드
                decoration: const InputDecoration(labelText: '닉네임 *'),
              ),
              TextField(
                controller: _emailController, // 이메일 입력 필드
                decoration: const InputDecoration(labelText: '이메일'),
              ),
              TextField(
                controller: _locationController, // 거주지역 입력 필드
                decoration: const InputDecoration(labelText: '거주지역'),
              ),
              TextField(
                controller: _ageController, // 나이 입력 필드
                decoration: const InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number, // 숫자 입력을 위한 키보드를 사용합니다.
              ),
              SizedBox(height: 20), // 위젯 간의 간격을 설정합니다.
              ElevatedButton(
                onPressed: () => _signup(context), // 회원가입 버튼을 눌렀을 때 호출되는 메서드입니다.
                child: Text('회원가입'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
