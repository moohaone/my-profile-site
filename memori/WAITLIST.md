# memori 대기자 명단 연결하기 (Google Sheets, 무료, 10분)

랜딩 페이지 세 개는 같은 폼 스크립트(`memori/assets/waitlist.js`)를 씁니다. 응답은 하나의 시트에 쌓이고 `variant` 열(`time` / `healthspan` / `care`)로 구분됩니다. `wtp`는 월 구독 지불 의사(건강수명·돌봄), `wtp_once`는 평생 구매 지불 의사(남은 시간)입니다.

1. Google Sheets에서 새 시트를 만들고 이름을 `memori-waitlist`로 짓습니다.
2. 메뉴 **확장 프로그램 → Apps Script**를 열고 아래 코드를 붙여넣습니다.

   ```js
   const COLUMNS = ['submitted_at', 'variant', 'email', 'finding', 'pain', 'lens', 'wtp', 'wtp_once',
     'utm_source', 'utm_medium', 'utm_campaign', 'utm_content', 'referrer'];

   function doPost(e) {
     const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
     if (sheet.getLastRow() === 0) sheet.appendRow(COLUMNS);
     const p = e.parameter;
     sheet.appendRow(COLUMNS.map((c) => p[c] || ''));
     return ContentService.createTextOutput('ok');
   }
   ```

3. **배포 → 새 배포 → 유형: 웹 앱**을 고릅니다. 실행 계정은 *나*, 액세스 권한은 *모든 사용자*로 설정합니다.
4. 발급된 `https://script.google.com/macros/s/.../exec` URL을 복사합니다.
5. `memori/assets/waitlist.js` 맨 위의 `WAITLIST_ENDPOINT = ''`에 붙여넣고 커밋합니다.

이 값이 비어 있으면 폼은 제출을 거부하고 "아직 연결되지 않았다"는 안내를 띄웁니다. 신청자가 조용히 유실되는 일은 없습니다.

## 광고·공유 링크에 UTM 붙이기

채널별 반응을 비교하려면 링크에 UTM 파라미터를 붙이세요.

- `.../memori/?utm_source=instagram&utm_campaign=healthspan_v1`
- `.../memori/care/?utm_source=naver_cafe&utm_campaign=care_v1`
