//
//  AuthorPage.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 22.12.2023.
//

import SwiftUI
import MessageUI

/*
 TODO: - Комбинация класса и уровней в фильтре, чтобы можно было задать каждому классу конкретные уровни заклинаний
 TODO: - Авторские отчисления в фильтр
 TODO: - Прелоад инфы
 TODO: - соединение в приложение
*/

struct AuthorPage: View {
    
    @State var isShowingMailView = false
    @State var result: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Я Варя Кузнецова, автор приложения")
            
            Text("В мои планы входит:")

            Text("- Добавление разных переводов скиллов")
            Text("- Комбинация класса и уровней в фильтре, чтобы можно было задать каждому классу конкретные уровни заклинаний")
            Text("- Конвертация в сайт и андроид-приложение")

            Text("")
            
            Text("Если у вас есть новые идеи или в приложении вы столкнулись с проблемами, пожалуйста,")
            
            Button("напишите мне") {
                print("ttt")
            }
            .disabled(!MFMailComposeViewController.canSendMail())
            .sheet(isPresented: $isShowingMailView) {
                MailView(result: self.$result)
            }
            Spacer()
        }
        .padding()
        .background(
            Color(uiColor: UIColor.systemGroupedBackground)
        )
        .navigationTitle("Hello, World!")
    }
}

#Preview {
    AuthorPage()
}
