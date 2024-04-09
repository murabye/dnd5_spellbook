//
//  AuthorPage.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 22.12.2023.
//

import SwiftUI
import MessageUI

/*
 TODO: VARVAR
 - возможность поправить скилл
 - возможность добавить свой скилл
 - возможность добавить свой тег
 - автоматическое добавление скиллов для друида и жреца
 - авторские отчисления в фильтре
 - оптимизации главной страницы
 - страничка создания уменьшить
 */

struct AuthorPage: View {
    
    @State var isShowingMailView = false
    @State var result: Result<MFMailComposeResult, Error>? = nil

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Я Варя Кузнецова, автор приложения")
                
                Text("В мои планы входит:")
                
                Text("- Добавление разных переводов скиллов")
                Text("- Конвертация в сайт и андроид-приложение")
                
                Text("")
                
                Text("Если у вас есть новые идеи или в приложении вы столкнулись с проблемами, пожалуйста,")
                
                Button("напишите мне") {
                    isShowingMailView.toggle()
                }
                .disabled(!MFMailComposeViewController.canSendMail())
                .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result)
                }
                Spacer()
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Hello, World!")
        .background(
            Color(uiColor: UIColor.systemGroupedBackground)
        )
    }
}

#Preview {
    AuthorPage()
}
