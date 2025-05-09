import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:sw_hackathon/providers/exercise_data.dart';

class Personalsetting extends StatefulWidget {
  const Personalsetting({super.key});
  
  @override
  State<Personalsetting> createState() => _PersonalsettingState();
}

class PersonalInfo {
  String role;
  String gender;
  int? age;
  String disabilityLevel;
  String disabilityType;

  PersonalInfo({
    required this.role,
    required this.gender,
    this.age,
    required this.disabilityLevel,
    required this.disabilityType,
  });

  @override
  String toString() {
    return '역할: $role, 성별: $gender, 나이: ${age ?? "미입력"}, 장애 등급: $disabilityLevel, 장애 분류: $disabilityType';
  }
}

class _PersonalsettingState extends State<Personalsetting> {
  int selectedRoleIndex = 0;
  int selectedGenderIndex = 0;
  int? calculatedAge;
  int selectedSpinalIndex = 0;

  final List<DataTab> userRoles = [DataTab(title: "본인"), DataTab(title: "보호자")];
  final List<DataTab> genders = [DataTab(title: "남성"), DataTab(title: "여성")];
  final List<String> disabilityLevels = [
    "1급", "2급", "3급", "4급", "5급", "6급", "불완전마비", "완전마비",
  ];
  final List<String> disabilityTypes = [
    "시각장애", "지적장애", "척수장애", "청각장애"
  ];

  late PersonalInfo userInfo;
  String selectedDisabilityLevel = "1급";
  String selectedDisabilityType = "청각장애";

  //데이터 연동 부분
  Future<void> saveUserInfoToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("로그인이 필요합니다.")),
      );
      return;
    }

    final uid = user.uid;

    // 저장할 데이터 Map으로 변환
    final userData = {
      "role": userInfo.role,
      "gender": userInfo.gender,
      "age": userInfo.age,
      "disabilityLevel": userInfo.disabilityLevel,
      "disabilityType": userInfo.disabilityType,
      "spinalDetail": selectedDisabilityType == "척수장애"
          ? ["T6이상", "T6미만", "사지마비"][selectedSpinalIndex]
          : null,
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      // 추천 운동 데이터 갱신
      final exerciseData = Provider.of<ExerciseData>(context, listen: false);
      await exerciseData.fetchRecommendedExercises(uid);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("개인정보가 저장되었습니다.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("저장 실패: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    userInfo = PersonalInfo(
      role: userRoles[selectedRoleIndex].title ?? "미입력",
      gender: genders[selectedGenderIndex].title ?? "미입력",
      disabilityLevel: selectedDisabilityLevel,
      disabilityType: selectedDisabilityType,
    );
  }

  // 사용자 정보 로드 함수 추가
  Future<void> loadUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          selectedRoleIndex = userRoles.indexWhere((r) => r.title == data['role']);
          selectedGenderIndex = genders.indexWhere((g) => g.title == data['gender']);
          calculatedAge = data['age'];
          selectedDisabilityLevel = data['disabilityLevel'];
          selectedDisabilityType = data['disabilityType'];
          if (data['spinalDetail'] != null) {
            selectedSpinalIndex = ["T6이상", "T6미만", "사지마비"].indexOf(data['spinalDetail']);
          }
          
          userInfo = PersonalInfo(
            role: data['role'],
            gender: data['gender'],
            age: data['age'],
            disabilityLevel: data['disabilityLevel'],
            disabilityType: data['disabilityType'],
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("데이터 로드 실패: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('개인설정', style: TextStyle(fontSize: 30)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("역할 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FlutterToggleTab(
              dataTabs: userRoles,
              width: 90,
              borderRadius: 20,
              selectedIndex: selectedRoleIndex,
              selectedBackgroundColors: [Color(0xFFA1C65C)],
              selectedTextStyle: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              unSelectedTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
              selectedLabelIndex: (index) {
                setState(() {
                  selectedRoleIndex = index;
                  userInfo.role = userRoles[index].title ?? '미입력';
                });
              },
            ),

            const SizedBox(height: 20),
            Text("성별 선택", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            FlutterToggleTab(
              dataTabs: genders,
              width: 90,
              borderRadius: 20,
              selectedIndex: selectedGenderIndex,
              selectedBackgroundColors: [Color(0xFFA1C65C)],
              selectedTextStyle: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              unSelectedTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
              selectedLabelIndex: (index) {
                setState(() {
                  selectedGenderIndex = index;
                  userInfo.gender = genders[index].title ?? '미입력';
                });
              },
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      calculatedAge = DateTime.now().year - picked.year;
                      userInfo.age = calculatedAge;
                    });
                  }
                },
                child: Text('생년월일 선택'),
              ),
            ),

            const SizedBox(height: 20),
            Text("장애 등급", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedDisabilityLevel,
              items: disabilityLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDisabilityLevel = newValue ?? '1급';
                  userInfo.disabilityLevel = newValue ?? "미입력";
                });
              },
            ),

            const SizedBox(height: 10),
            Text("장애 분류", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: selectedDisabilityType,
              items: disabilityTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedDisabilityType = newValue ?? '청각장애';
                  userInfo.disabilityType = newValue ?? "미입력";
                });
              },
            ),

            if (selectedDisabilityType == '척수장애') ...[
              const SizedBox(height: 20),
              FlutterToggleTab(
                width: 90,
                borderRadius: 20,
                selectedIndex: selectedSpinalIndex,
                selectedBackgroundColors: [Color(0xFFA1C65C)],
                selectedTextStyle: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                unSelectedTextStyle: TextStyle(color: Colors.black87, fontSize: 16),
                dataTabs: [
                  DataTab(title: 'T6이상'),
                  DataTab(title: 'T6미만'),
                  DataTab(title: '사지마비'),
                ],
                selectedLabelIndex: (index) {
                  setState(() {
                    selectedSpinalIndex = index;
                  });
                },
              ),
            ],
            
              Card(
                margin: EdgeInsets.symmetric(horizontal: 16.0),
                color: Colors.grey.shade100,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    '역할: ${userInfo.role}\n'
                    '성별: ${userInfo.gender}\n'
                    '나이: ${userInfo.age ?? "미입력"}\n'
                    '장애 등급: ${userInfo.disabilityLevel}\n'
                    '장애 분류: ${userInfo.disabilityType}\n'
                    '척수장애 세부: ${selectedDisabilityType == "척수장애" ? ["T6이상", "T6미만", "사지마비"][selectedSpinalIndex] : "해당 없음"}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  saveUserInfoToFirestore();
                  print(userInfo.toString());
                  Navigator.pop(context);
                },
                icon: Icon(Icons.save),
                label: Text("개인정보 저장"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[400],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}