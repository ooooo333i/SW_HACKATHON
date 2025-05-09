import firebase_admin
from firebase_admin import credentials, firestore

# Firebase 초기화 (서비스 계정 키 JSON 경로 설정)
cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

# Firestore DB 객체 가져오기
db = firestore.client()

exercises = [
    {"name": "앉았다 일어서기", "description": "하체 근력과 균형을 향상시키는 기본 운동입니다.", "youtube_link": ""},
    {"name": "파워클린", "description": "전신 근력과 폭발적인 파워를 기르는 역도 동작입니다.", "youtube_link": ""},
    {"name": "앉아서 모으기", "description": "내전근을 강화하기 위한 머신 운동입니다.", "youtube_link": ""},
    {"name": "바벨 끌어당기기", "description": "등 근육과 팔을 단련하는 리프팅 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 다리 모으기", "description": "허벅지 안쪽 근육을 강화하는 운동입니다.", "youtube_link": ""},
    {"name": "허리 굽혀 덤벨 들기", "description": "등과 하체 근육을 단련하는 데드리프트 동작입니다.", "youtube_link": ""},
    {"name": "바벨들어올리기", "description": "전신 근력을 향상시키는 고중량 리프팅 운동입니다.", "youtube_link": ""},
    {"name": "옆구리늘리기", "description": "몸통 옆면의 유연성과 근육을 강화합니다.", "youtube_link": ""},
    {"name": "비스듬히 누워서 밀기", "description": "가슴과 팔의 근육을 강화하는 머신 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 몸통 움츠리기", "description": "복직근을 강화하는 복근 운동입니다.", "youtube_link": ""},
    {"name": "원판던지기", "description": "전신 협응력과 팔 근력을 키우는 스포츠 동작입니다.", "youtube_link": ""},
    {"name": "앉아서 팔꿈치 굽히기/펴기", "description": "팔꿈치 관절 운동 범위를 확보하는 데 도움을 줍니다.", "youtube_link": ""},
    {"name": "앉아서 다리 벌리기", "description": "엉덩이 바깥쪽과 대퇴근을 강화하는 운동입니다.", "youtube_link": ""},
    {"name": "거꾸로 누워서 밀기", "description": "하체 근육을 강화하는 레그프레스 응용 동작입니다.", "youtube_link": ""},
    {"name": "손목 펴기/굽히기", "description": "전완근을 단련하는 손목 근력 운동입니다.", "youtube_link": ""},
    {"name": "실내 자전거타기", "description": "심폐 지구력과 하체 근력 향상에 좋은 유산소 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 위로 밀기", "description": "어깨 근육을 강화하는 숄더 프레스 동작입니다.", "youtube_link": ""},
    {"name": "의자 앞에서 앉았다 일어서기", "description": "노약자에게 적합한 하체 근력 강화 운동입니다.", "youtube_link": ""},
    {"name": "한발 앞으로 내밀고 앉았다 일어서기", "description": "균형과 하체 근력을 동시에 강화하는 런지 응용 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 당겨 내리기", "description": "광배근을 단련하는 랫풀다운 머신 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 다리 굽히기", "description": "햄스트링을 강화하는 머신 운동입니다.", "youtube_link": ""},
    {"name": "누워서 머리 위로 팔꿈치 펴기", "description": "삼두근을 강화하는 트라이셉 익스텐션 동작입니다.", "youtube_link": ""},
    {"name": "엎드려서 균형잡기", "description": "코어와 균형 감각을 향상시키는 전신 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 뒤로 당기기", "description": "상체 뒷면을 단련하는 시티드 로우 운동입니다.", "youtube_link": ""},
    {"name": "턱걸이", "description": "등, 팔, 어깨를 단련하는 대표적인 체중 운동입니다.", "youtube_link": ""},
    {"name": "서서 어깨 들어올리기", "description": "승모근을 강화하는 슈러그 동작입니다.", "youtube_link": ""},
    {"name": "바벨 들어 팔꿈치 굽히기", "description": "이두근을 단련하는 바벨 컬 운동입니다.", "youtube_link": ""},
    {"name": "윗몸 말아 올리기", "description": "복근을 자극하는 크런치 운동입니다.", "youtube_link": ""},
    {"name": "서서 바벨 위로 밀기", "description": "어깨 전면을 단련하는 오버헤드 프레스 동작입니다.", "youtube_link": ""},
    {"name": "매달려서 다리 들기", "description": "복직근 하부를 집중적으로 단련하는 운동입니다.", "youtube_link": ""},
    {"name": "고정한 상태에서 덤벨 들고 팔꿈치 굽히기", "description": "팔의 이두근을 단련하는 컨센트레이션 컬 운동입니다.", "youtube_link": ""},
    {"name": "엎드려서 다리 차올리기", "description": "둔근과 허리 근육을 강화하는 힙 익스텐션 운동입니다.", "youtube_link": ""},
    {"name": "서서 균형잡으며 몸통 회전하기", "description": "코어와 균형을 강화하는 몸통 회전 운동입니다.", "youtube_link": ""},
    {"name": "서서 상체 일으키기", "description": "복근과 고관절을 자극하는 굿모닝 동작입니다.", "youtube_link": ""},
    {"name": "앉아서 밀기", "description": "가슴 근육을 강화하는 머신 프레스 운동입니다.", "youtube_link": ""},
    {"name": "뒤꿈치 들기", "description": "종아리 근육을 강화하는 카프 레이즈 동작입니다.", "youtube_link": ""},
    {"name": "트레드밀에서 걷기", "description": "가장 기본적인 유산소 운동으로, 심폐 기능을 강화합니다.", "youtube_link": ""},
    {"name": "누워서 밀기", "description": "하체 근력 향상에 효과적인 레그프레스 머신 운동입니다.", "youtube_link": ""},
    {"name": "허리 굽혀 덤벨 뒤로 들기", "description": "삼각근 후면과 등 근육을 단련합니다.", "youtube_link": ""},
    {"name": "발 닿기", "description": "복근을 자극하는 바디웨이트 중심의 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 다리 밀기", "description": "허벅지 근력을 강화하는 레그 익스텐션 운동입니다.", "youtube_link": ""},
    {"name": "몸통 들어올리기", "description": "복근과 코어를 강화하는 복부 리프트 운동입니다.", "youtube_link": ""},
    {"name": "앉아서 다리 펴기", "description": "대퇴사두근을 자극하는 레그 익스텐션 머신 운동입니다.", "youtube_link": ""},
    {"name": "덤벨 옆으로 들어올리기", "description": "삼각근 측면을 강화하는 레터럴 레이즈입니다.", "youtube_link": ""},
    {"name": "짝 운동", "description": "두 사람이 함께 수행하는 협응 운동입니다.", "youtube_link": ""},
    {"name": "몸통 옆으로 굽히기", "description": "복사근을 강화하는 사이드 밴드 운동입니다.", "youtube_link": ""}
]

collection_name = "exercise_list"

for exercise in exercises:
    db.collection(collection_name).add(exercise)

print("업로드 완료")