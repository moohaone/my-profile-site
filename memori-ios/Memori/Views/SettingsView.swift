import SwiftData
import SwiftUI

struct SettingsView: View {
    @AppStorage(Profile.birthDateKey, store: .shared) private var birthInterval: Double = 0
    @AppStorage(Profile.lifeExpectancyKey, store: .shared) private var lifeExpectancy = LifeMath.defaultLifeExpectancy
    @AppStorage(Profile.monthlyIncomeKey, store: .shared) private var monthlyIncome = 0
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let birthDate = Binding(
            get: { Date(timeIntervalSinceReferenceDate: birthInterval) },
            set: { birthInterval = $0.timeIntervalSinceReferenceDate }
        )

        NavigationStack {
            Form {
                Section("나") {
                    DatePicker("생년월일", selection: birthDate, in: ...Date.now, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "ko_KR"))
                }

                Section {
                    Stepper(value: $lifeExpectancy, in: 60...110, step: 0.5) {
                        HStack {
                            Text("기준 수명")
                            Spacer()
                            Text("\(lifeExpectancy.formatted())세").foregroundStyle(Color.mMuted)
                        }
                    }
                    if lifeExpectancy != LifeMath.defaultLifeExpectancy {
                        Button("기본값으로 되돌리기") { lifeExpectancy = LifeMath.defaultLifeExpectancy }
                    }
                } footer: {
                    Text("기본값 83.7세는 국가데이터처 「2024년 생명표」의 기대수명입니다. 평균일 뿐, 운명이 아닙니다.")
                }

                Section {
                    TextField("월 실수령액", value: $monthlyIncome, format: .number)
                        .keyboardType(.numberPad)
                } header: {
                    Text("돈")
                } footer: {
                    Text("물건의 가격을 노동 시간으로 바꾸는 데만 씁니다. 주 40시간, 월 209시간 기준입니다.")
                }

                Section {
                    Text("모든 데이터는 이 기기에만 저장됩니다. 광고도, 추적도 없습니다.")
                        .font(.mCaption)
                        .foregroundStyle(Color.mMuted)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.mBackground)
            .navigationTitle("설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        WidgetSync.publish(context: context)
                        dismiss()
                    }
                }
            }
        }
    }
}
