import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';

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
}

class _PersonalsettingState extends State<Personalsetting> {
  int selectedRoleIndex = 0;
  int selectedGenderIndex = 0;
  int? calculatedAge;

  final List<DataTab> userRoles = [DataTab(title: "본인"), DataTab(title: "보호자")];
  final List<DataTab> genders = [DataTab(title: "남성"), DataTab(title: "여성")];

  final List<String> disabilityLevels = [
    "1급", "2급", "3급", "4급", "5급", "6급", "불완전마비", "완전마비",
  ];
  final List<String> disabilityTypes = [
    "시각장애", "지적장애", "척수장애", "청각장애",
  ];

  late PersonalInfo userInfo;
  String selectedDisabilityLevel = "1급";
  String selectedDisabilityType = "청각장애";
  int selectedSpinalIndex = 0; // 척수장애 하위 선택을 위한 변수

  @override
  void initState() {
    super.initState();
    userInfo = PersonalInfo(
      role: userRoles[selectedRoleIndex].title ?? "미입력",
      gender: genders[selectedGenderIndex].title ?? "미입력",
      disabilityLevel: selectedDisabilityLevel,
      disabilityType: selectedDisabilityType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('개인설정', style: TextStyle(fontSize: 30))),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

              // 역할 선택
              FlutterToggleTab(
                dataTabs: userRoles,
                width: 90,
                borderRadius: 20,
                selectedIndex: selectedRoleIndex,
                selectedBackgroundColors: [const Color.fromARGB(255, 161, 198, 92)],
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                unSelectedTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                selectedLabelIndex: (index) {
                  setState(() {
                    selectedRoleIndex = index;
                    userInfo.role = userRoles[index].title ?? '미입력';
                  });
                },
              ),

              const SizedBox(height: 20),

              // 성별 선택
              FlutterToggleTab(
                dataTabs: genders,
                width: 90,
                borderRadius: 20,
                selectedIndex: selectedGenderIndex,
                selectedBackgroundColors: [const Color.fromARGB(255, 161, 198, 92)],
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                unSelectedTextStyle: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                selectedLabelIndex: (index) {
                  setState(() {
                    selectedGenderIndex = index;
                    userInfo.gender = genders[index].title ?? '미입력';
                  });
                },
              ),

              const SizedBox(height: 20),

              // 생년월일 선택 → 나이 저장
              ElevatedButton(
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
                child: const Text('생년월일 선택'),
              ),

              const SizedBox(height: 20),

              // 장애 등급 선택 (드롭다운 메뉴)
              DropdownButton<String>(
                value: selectedDisabilityLevel,
                hint: const Text('장애 등급 선택'),
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

              // 장애 분류 선택 (드롭다운 메뉴)
              DropdownButton<String>(
                value: selectedDisabilityType,
                hint: const Text('장애 분류 선택'),
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

              // 척수장애 선택 시, 추가 선택지 표시
              if (selectedDisabilityType == '척수장애') ...[
                const SizedBox(height: 20),
                FlutterToggleTab(
                  width: 90,
                  borderRadius: 20,
                  selectedIndex: selectedSpinalIndex,
                  selectedBackgroundColors: [const Color.fromARGB(255, 161, 198, 92)],
                  selectedTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  unSelectedTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
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

              const SizedBox(height: 20),

              // 결과 출력
              Text(
                '역할: ${userInfo.role}\n성별: ${userInfo.gender}\n나이: ${userInfo.age ?? "미입력"}\n장애 등급: ${userInfo.disabilityLevel}\n장애 분류: ${userInfo.disabilityType}\n척수장애 세부: ${selectedDisabilityType == "척수장애" ? ["T6이상", "T6미만", "사지마비"][selectedSpinalIndex] : "해당 없음"}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}