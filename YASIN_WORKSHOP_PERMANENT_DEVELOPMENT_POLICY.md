# معمل ياسين
# YASIN WORKSHOP — PERMANENT DEVELOPMENT POLICY

> الإصدار الأول — السياسة العليا للمشروع

---

## [1. تعريف المشروع]

اسم المشروع: معمل ياسين

الاسم التقني: YASIN_WORKSHOP

المسار الرسمي: D:\YASIN_WORKSHOP

هذا مشروع جديد مستقل تمامًا يُبنى من الصفر.

يُمنع اعتبار مشروع LUMAR أو أي مشروع سابق مصدرًا للكود أو قاعدة البيانات أو العقود أو البنية لهذا المشروع.

يجوز الاستفادة من المبادئ الهندسية العامة والخبرات الناجحة فقط، لكن أي كود أو تصميم أو عقد أو جدول أو قاعدة أعمال خاصة بمشروع آخر لا تنتقل إلى معمل ياسين إلا بتفويض صريح من المالك.

وثيقة متطلبات معمل ياسين المعتمدة هي مصدر الحقيقة لقواعد الأعمال Business Rules (قواعد الأعمال).

هذه السياسة هي مصدر الحقيقة لقواعد التطوير والواجهة والأمان والأداء.

## [1A. عقد قواعد بيانات معمل ياسين وعزل LUMAR]

### [A1. محرك قاعدة البيانات الرسمي]

محرك قاعدة البيانات الرسمي لمشروع معمل ياسين هو:

Microsoft SQL Server

المثيل المعتمد حاليًا:

YASIN-YASIN\SQLEXPRESS

PostgreSQL ليس محرك قاعدة البيانات الرسمي لهذا المشروع.

أي نص تقني سابق داخل أي وثيقة للمشروع يذكر PostgreSQL كقاعدة البيانات الرسمية أو التقنية المختارة يجب تحديثه إلى Microsoft SQL Server دون تغيير بقية محتوى الوثيقة.

### [A2. قاعدة التطوير والتحقق الرسمية الوحيدة]

قاعدة التطوير والتحقق الرسمية الوحيدة لمشروع معمل ياسين هي:

YASIN_WORKSHOP_ES_VALIDATION

وهي القاعدة الوحيدة المسموح استخدامها، وفق نطاق المهمة والتفويض، في:

- التطوير اليومي.
- إنشاء Schema المعتمد.
- Migrations المعتمدة.
- إنشاء وتعديل الجداول والأعمدة والعلاقات والقيود والفهارس.
- Views و Stored Procedures عند الحاجة.
- بيانات الاختبار.
- اختبارات Backend.
- اختبارات API.
- اختبارات Flutter.
- الاختبارات التكاملية.
- التحقق الحي خلال التطوير.

أي عملية كتابة تخص التطوير يجب أن يكون هدفها مثبتًا صراحة على:

YASIN_WORKSHOP_ES_VALIDATION

قبل التنفيذ.

### [A3. القاعدة الذهبية]

القاعدة الذهبية الرسمية للمشروع هي:

YASIN_WORKSHOP_GOLDEN_1

وظيفتها:

Golden Baseline
(الخط الأساسي الذهبي النظيف والمعتمد).

هذه القاعدة ليست قاعدة التطوير اليومي.

يُمنع عليها افتراضيًا:

- Migrations.
- ALTER.
- CREATE / DROP لأغراض التطوير اليومي.
- Seed تجريبي.
- بيانات اختبار.
- Data Fix.
- Schema Fix.
- اختبارات تكتب بيانات.
- تشغيل التطبيق التطويري عليها بغرض التجربة.
- أي DDL أو DML غير مفوض صراحة.

لا تتم ترقية:

YASIN_WORKSHOP_GOLDEN_1

من:

YASIN_WORKSHOP_ES_VALIDATION

إلا عبر:

Baseline Promotion
(ترقية الخط الأساسي)

بأمر مستقل وصريح ومباشر من مالك المشروع ياسين.

نجاح مهمة في قاعدة التطوير لا يمثل إذنًا تلقائيًا لتعديل القاعدة الذهبية.

### [A4. العزل التام عن LUMAR]

مشروع معمل ياسين مستقل 100% عن مشروع LUMAR.

جميع قواعد بيانات LUMAR الموجودة على:

YASIN-YASIN\SQLEXPRESS

تعتبر خارج نطاق الكتابة لمشروع معمل ياسين.

يُمنع منعًا باتًا تنفيذ أي كتابة عليها بسبب مهمة تخص معمل ياسين.

يشمل المنع، دون حصر:

INSERT
UPDATE
DELETE
MERGE
CREATE
ALTER
DROP
TRUNCATE
Migration
Seed
Schema Fix
Data Fix
Index Creation
Stored Procedure modification
Function modification
View modification
RESTORE
ATTACH
DETACH
Rename
Backup overwrite
أو أي DDL/DML آخر.

ولا يجوز لمشروع معمل ياسين:

- استخدام قاعدة LUMAR كقاعدة اختبار.
- استخدام قاعدة LUMAR كقاعدة تطوير.
- استخدام قاعدة LUMAR كقاعدة ذهبية.
- استخدام بيانات LUMAR كبذور تشغيل تلقائية.
- تشغيل Migration خاصة بمعمل ياسين على LUMAR.
- إعادة استخدام Connection String الخاص بـLUMAR.
- تنفيذ اختبارات كتابية ضد LUMAR.
- إصلاح عيب في LUMAR أثناء تنفيذ مهمة معمل ياسين مهما بدا الإصلاح بسيطًا.

### [A5. استثناء القراءة فقط من LUMAR]

حتى القراءة من قواعد LUMAR ليست جزءًا طبيعيًا من مهام معمل ياسين.

يسمح بالقراءة فقط من قاعدة LUMAR عندما يطلب مالك المشروع ياسين ذلك صراحةً لغرض محدد.

عند وجود هذا التفويض:

- القراءة فقط.
- SELECT فقط بقدر الحاجة.
- لا كتابة.
- لا تعديل.
- لا Migration.
- لا إصلاح.
- لا تنظيف.
- لا Seed.
- لا إنشاء كائنات.
- لا تغيير إعدادات القاعدة.

وإذا اكتشف المنفذ مشكلة داخل LUMAR أثناء قراءة مصرح بها ضمن مهمة معمل ياسين:

يبلغ المالك فقط.

ولا يصلحها ضمن مشروع معمل ياسين.

### [A6. بوابة هوية القاعدة]

قبل أي عملية قاعدة بيانات كتابية في مشروع معمل ياسين يجب إثبات هوية الهدف.

الهوية المقبولة للتطوير العادي:

SERVER:
YASIN-YASIN\SQLEXPRESS

DATABASE:
YASIN_WORKSHOP_ES_VALIDATION

إذا كانت DB_NAME() أو Connection String أو أي دليل آخر يشير إلى قاعدة مختلفة:

STOP.

لا تنفذ الكتابة.

إذا كان الهدف:

YASIN_WORKSHOP_GOLDEN_1

STOP أيضًا، إلا إذا كان هناك تفويض مستقل وصريح للقاعدة الذهبية.

إذا كان اسم القاعدة يبدأ بـ LUMAR أو ثبت أنها تابعة لـLUMAR:

STOP فورًا.

ممنوع الاعتماد على الافتراض أو اسم الاتصال المعروض في الواجهة فقط قبل العمليات الحساسة.

### [A7. سياسة Connection String]

Backend الخاص بمعمل ياسين يجب أن يستخدم Connection Configuration خاصة بمعمل ياسين.

بيئة التطوير يجب أن تستهدف:

YASIN_WORKSHOP_ES_VALIDATION

ولا يجوز نسخ Connection String من مشروع LUMAR ثم ترك Database Name القديم بصورة قد تؤدي إلى كتابة عرضية.

يجب أن يكون إعداد الاتصال واضحًا وقابلًا للتحقق.

أي Test Configuration كتابية يجب أن تستهدف قاعدة معمل ياسين المصرح بها وفق سياسة الاختبار المعتمدة، وليس أي قاعدة LUMAR.

### [A8. العقد الحالي لقاعدة البيانات]

الحالة الرسمية الحالية:

DATABASE ENGINE:
Microsoft SQL Server

SQL SERVER INSTANCE:
YASIN-YASIN\SQLEXPRESS

OFFICIAL DEVELOPMENT / VALIDATION DATABASE:
YASIN_WORKSHOP_ES_VALIDATION

OFFICIAL GOLDEN BASELINE DATABASE:
YASIN_WORKSHOP_GOLDEN_1

PRODUCTION DATABASE:
NOT CREATED YET

POSTGRESQL:
NOT USED FOR THIS PROJECT

LUMAR DATABASES:
OUTSIDE YASIN WORKSHOP WRITE SCOPE

أي قاعدة أخرى غير القاعدتين الرسميتين لا تصبح قاعدة معتمدة لمعمل ياسين لمجرد وجودها على نفس SQL Server Instance.

إنشاء قاعدة ثالثة مستقبلًا، بما فيها Production، يحتاج قرارًا وتفويضًا مستقلًا من المالك.

### [A9. قواعد الحظر والسلطة]

- لا يتم تنفيذ أي كتابة على قاعدة إلا بعد التحقق من هوية الهدف.
- لا يتم تنفيذ Baseline Promotion دون OWNER EXPLICIT AUTHORIZATION.
- لا يتم استخدام LUMAR كقاعدة تطوير أو اختبار أو ذهبية.
- لا يتم تعديل أي قاعدة LUMAR أثناء تنفيذ مهام معمل ياسين.
- لا يتم تنفيذ أي DDL أو DML على أي قاعدة غير المصرح بها.
- لا يتم اعتبار قاعدة موجودة على نفس المثيل قاعدة معمل ياسين تلقائيًا.
- لا يتم تفسير التعويض الإضافي أو التشغيل الحقيقي كإذن تلقائي للكتابة.

LUMAR READ-ONLY
يُسمح به فقط عند طلب صريح من المالك لغرض محدد، ولا يتجاوز SELECT بقدر الحاجة.

OWNER EXPLICIT AUTHORIZATION
هو التفويض المباشر والكتابي/المباشر من مالك المشروع ياسين لتغيير أي قاعدة ذهبية أو إجراء ترقية خط أساسي أو تغيير نطاق إدارة قاعدة البيانات.

جميع هذه القواعد هي جزء لا يتجزأ من السياسة الدائمة، وتُطبق على كل فريق وبنية ومشروع مرتبط بمعمل ياسين.

============================================================
GOLDEN BASELINE PROMOTION GATE
بوابة ترقية القاعدة الذهبية
============================================================

قاعدة التطوير والتحقق الرسمية:

YASIN_WORKSHOP_ES_VALIDATION

القاعدة الذهبية:

YASIN_WORKSHOP_GOLDEN_1

1. جميع أعمال التطوير والاختبارات والترحيلات وتعديلات قاعدة البيانات
تتم أولًا حصريًا على:

YASIN_WORKSHOP_ES_VALIDATION

2. لا يجوز تعديل YASIN_WORKSHOP_GOLDEN_1 تلقائيًا أثناء تنفيذ أي مهمة.

3. إذا اكتملت مهمة بالكامل وصدر لها حكم A مثبت، وكان لهذه المهمة أثر
معتمد على قاعدة البيانات يجب أن يصبح جزءًا من الخط الأساسي، مثل:

- Schema.
- Tables.
- Columns.
- Relationships.
- Constraints.
- Indexes.
- Views.
- Stored Procedures.
- Functions.
- Migrations.
- إعدادات أو بيانات مرجعية دائمة معتمدة.

فلا تعتبر هذه التغييرات مرقاة إلى Golden تلقائيًا.

4. بعد إغلاق هذه المهمة بالحكم A يجب على المنفذ التقني أن يذكر صراحة
في تقريره:

GOLDEN_BASELINE_PROMOTION_REQUIRED=YES

ثم يطلب من مالك المشروع ياسين صراحةً تفويض:

Baseline Promotion

من:

YASIN_WORKSHOP_ES_VALIDATION

إلى:

YASIN_WORKSHOP_GOLDEN_1

5. ممنوع تنفيذ Baseline Promotion قبل موافقة صريحة ومباشرة من ياسين.

6. طلب التفويض ليس تفويضًا.

7. الحكم A للمهمة ليس تفويضًا.

8. نجاح Migration على ES_VALIDATION ليس تفويضًا.

9. نجاح الاختبارات ليس تفويضًا.

10. فقط موافقة المالك الصريحة على Baseline Promotion تسمح بالكتابة على
YASIN_WORKSHOP_GOLDEN_1.

11. قبل أي Baseline Promotion مصرح بها يجب تنفيذ تدقيق قراءة فقط للقاعدتين
وتحديد:

- هوية SQL Server.
- هوية القاعدتين.
- Schema الحالي.
- الفروقات المطلوب ترقيتها.
- أن الفروقات تعود إلى مهام مغلقة ومعتمدة.
- عدم وجود بيانات اختبار يجب نقلها.
- المخاطر.
- خطة التراجع.
- النسخة الاحتياطية المطلوبة.

12. يجب إنشاء Backup مناسب للقاعدة الذهبية قبل الترقية والتحقق منه وفق
سياسة المشروع.

13. Baseline Promotion تنقل فقط الحالة المعتمدة المقصودة.

ممنوع نقل بيانات الاختبار التشغيلية من ES_VALIDATION إلى GOLDEN.

14. بعد الترقية يجب إعادة التحقق من:

- Schema.
- العلاقات.
- القيود.
- الفهارس.
- الكائنات المعتمدة.
- البيانات المرجعية المعتمدة.
- Database Integrity.
- عدم وجود بيانات اختبار غير مصرح بها.

15. يجب إصدار رقم Baseline Version لكل ترقية ذهبية ناجحة، مثل:

YWS-BL-001
YWS-BL-002
YWS-BL-003

ويستخدم رقم الإصدار في تقرير الترقية والنسخة الاحتياطية والتحقق.

16. إذا كانت المهمة لا تغير قاعدة البيانات أو لا يوجد فيها أثر يجب إدخاله
إلى Golden، مثل مهمة Flutter بحتة، يسجل:

GOLDEN_BASELINE_PROMOTION_REQUIRED=NO

ولا يطلب ترقية بلا داعٍ.

17. إذا كانت المهمة مرتبطة بقاعدة البيانات لكنها لم تصل إلى الحكم A،
يسجل:

GOLDEN_BASELINE_PROMOTION_ALLOWED=NO

وتبقى Golden دون مساس.

18. لا يجوز تراكم تعديلات قاعدة بيانات مغلقة ومعتمدة بصمت دون التنبيه للمالك.
بعد كل إغلاق مؤهل للترقية يجب أن يوضح المنفذ حالة Golden في تقريره.

19. تظل قواعد LUMAR خارج النطاق بالكامل ولا تدخل في أي مقارنة أو Promotion
خاصة بمعمل ياسين.

============================================================
REQUIRED TASK REPORT EXTENSION
============================================================

من الآن فصاعدًا تضيف جميع تقارير المهام الحقول التالية:

DATABASE_IMPACT=
ES_VALIDATION_CHANGED=
DATABASE_CHANGE_VERIFIED=
TASK_FINAL_VERDICT=

GOLDEN_BASELINE_PROMOTION_REQUIRED=
GOLDEN_BASELINE_PROMOTION_ALLOWED=
GOLDEN_CURRENT_STATUS=

إذا كانت REQUIRED=YES وTASK_FINAL_VERDICT=A:

OWNER_BASELINE_PROMOTION_AUTHORIZATION_REQUESTED=YES

ولا ينفذ Promotion حتى يرد المالك بالموافقة الصريحة.

============================================================
ONLINE + OFFLINE FIRST — PERMANENT MANDATORY CONTRACT
============================================================

[MISSION]

من الآن فصاعدًا تسرى هذه السياسة على جميع التطويرات والواجهات والخدمات والاختبارات في:

D:\YASIN_WORKSHOP

ولا يتم اعتبار أي شاشة أو وحدة أو خدمة مكتملة إذا كانت تعمل فقط عند اتصال Backend الحقيقي وتتعطل عند انقطاع الشبكة أو Backend، عندما تكون الوظيفة قابلة للتنفيذ محليًا بأمان.

لذلك:

- جميع الشاشات الحالية والمستقبلية تخضع لهذا العقد.
- جميع الوحدات والواجهات والخدمات في Flutter تخضع لهذا العقد.
- جميع عقود Backend الجديدة تخضع لهذا العقد.
- جميع اختبارات القبول والتكامل والوظائف والواجهة تخضع لهذا العقد.
- أي Refactoring أو تطوير مستقبلي يجب تقييمه ضمن هذا العقد.

============================================================
[OWNER PERMANENT DECISION]
============================================================

قرار المالك ياسين:

«مشروع معمل ياسين يجب أن يُبنى Online + Offline First من أساسه.

لا يجوز اعتبار أي شاشة أو وظيفة تشغيلية مكتملة إذا كانت تعمل بصورة صحيحة عند الاتصال فقط وتتعطل بالكامل عند انقطاع Backend أو الشبكة، متى كانت الوظيفة قابلة للتنفيذ محليًا بأمان.

يجب تصميم التطبيق بحيث يستطيع المستخدم تصفح البيانات التشغيلية المتاحة محليًا والعمل على الوظائف المسموح بها Offline، ثم تتم المزامنة بأمان عند عودة الاتصال، دون فقد البيانات أو تكرار العمليات أو الكتابة فوق التعارضات بصمت.»

============================================================
[CORE RULE]
============================================================

من الآن:

لا يجوز إنشاء شاشة أو خدمة جديدة على نمط:

UI → HTTP → Backend → Response → UI

بحيث تصبح عديمة الفائدة تمامًا عند اختفاء الشبكة أو Backend.

المسار الافتراضي للخدمات والواجهات التي تدعم Offline هو:

UI → Local Store → UI

وبصورة مستقلة:

Local Outbox → Sync Engine → Backend

ثم:

Backend Changes → Pull Sync → Local Store → UI

============================================================
[OFFLINE FOUNDATION — FOUNDATION CENTRAL SHARED]
============================================================

يُعدّ الأساس المركزي العام لـ Online + Offline First جزءًا رسميًا من بنية المشروع:

- Local persistence هو واجهة موحدة للحفظ المحلي.
- Outbox هو صندوق عمليات دائم يظل موجودًا عبر إغلاق التطبيق وإعادة التشغيل.
- Operation identity و Entity identity و Operation type و Idempotency key هي حقول إلزامية لأي عملية قابلة للتزامن.
- Base version / Server version هي آلية تعارض رسمية عند الحاجة.
- كل وحدة مستقبلية لا تبني محركًا منفصلًا لكل شاشة؛ بل تتكامل عبر Adapter موحد مع Foundation المركزي نفسه.
- يبقى Customer path هو Reference Implementation للاعتماد والتحقق، مع الحفاظ على سلوكه الحالي في حال التعميم.

لا يجوز إنشاء محرك Offline مستقل لكل وحدة دون توحيدها عبر هذا الأساس المركزي.

============================================================
[READ OFFLINE]
============================================================

المطلوب ليس Offline Write فقط.

التطبيق يجب أن يستطيع، بحسب العقود والبيانات التي تمت مزامنتها سابقًا، عرض البيانات المحلية عند انقطاع الاتصال.

الهدف التشغيلي:

إذا فتح المستخدم التطبيق والخادم غير متاح، لا تصبح الشاشات فارغة فقط لأن HTTP غير متوفر.

تعرض آخر حالة محلية موثوقة متاحة.

ويجب تمييزها للمستخدم بوضوح عند الحاجة بأنها بيانات محلية أو منتظرة للمزامنة.

============================================================
[WRITE OFFLINE]
============================================================

أي عملية يسمح عقد الأعمال بتنفيذها محليًا يجب أن:

1. تحفظ محليًا أولًا بصورة دائمة.
2. تظهر للمستخدم مباشرة.
3. تسجل Outbox Operation.
4. لا تضيع عند إغلاق التطبيق.
5. لا تضيع عند إعادة تشغيل Windows.
6. تتم مزامنتها تلقائيًا عند عودة Backend.
7. لا تنفذ مرتين بسبب Retry.

============================================================
[LOCAL DATA IS NOT TEMPORARY CACHE]
============================================================

قاعدة البيانات المحلية ليست Cache مؤقتة فقط.

هي جزء رسمي من معمارية التطبيق Offline First.

يجب أن تدعم:

- القراءة المحلية.
- الكتابة المحلية المسموحة.
- حالة المزامنة.
- Outbox.
- Checkpoint.
- Conflict Records.
- Local Schema Version.
- Local Migrations عند الحاجة.

============================================================
[SINGLE UI — NOT TWO APPLICATIONS]
============================================================

ممنوع إنشاء:

Online Screen

وشاشة أخرى منفصلة باسم:

Offline Screen

لنفس الوظيفة.

المستخدم يتعامل مع الشاشة التشغيلية نفسها.

الشاشة نفسها تتعامل مع:

Online
Offline
Pending
Syncing
Synced
Conflict
Failed

من خلال الطبقات المركزية.

============================================================
[SYNC STATES]
============================================================

يجب أن تكون حالات المزامنة مركزية وواضحة، مثل:

LocalOnly
Pending
Syncing
Synced
Conflict
Failed

ولا يجوز عرض Pending للمستخدم على أنه Synced.

============================================================
[ONLINE IS NOT THE ONLY SOURCE FOR UI]
============================================================

لا يجوز أن تطلب كل شاشة من Backend في كل مرة لإظهار البيانات إذا كانت البيانات قابلة للحفظ والمزامنة محليًا.

يجب أن تمر الشاشات عبر Repository أو Local Store موحد وفق المعمارية المعتمدة.

ولا يجوز لكل شاشة اختراع منطق Offline خاص بها.

============================================================
[OUTBOX — MANDATORY]
============================================================

أي كتابة تدعم Offline يجب أن تستخدم Outbox دائمًا أو العقد المركزي المكافئ.

المطلوب:

- OperationId.
- IdempotencyKey.
- Entity identity.
- Operation type.
- Payload.
- Created time.
- Retry/attempt information.
- Sync state.

أو تصميم أفضل يحافظ على المعاني نفسها.

============================================================
[IDEMPOTENCY — MANDATORY]
============================================================

إعادة المزامنة لا يجوز أن تكرر العملية.

السيناريو الإلزامي:

Flutter يرسل
→ Backend ينفذ
→ الرد يضيع
→ Flutter يعيد
→ Backend لا ينفذ نفس العملية مرة ثانية.

Exactly Once Logical Effect

قاعدة دائمة.

============================================================
[PUSH + PULL — BOTH REQUIRED]
============================================================

Offline First لا يعني رفع البيانات المحلية فقط.

كل وحدة مناسبة للمزامنة يجب أن تدعم:

PUSH

و:

PULL

حتى تبقى قاعدة الجهاز متوافقة مع المصدر المركزي.

============================================================
[CONFLICTS]
============================================================

ممنوع اعتماد:

Last Writer Wins

كقاعدة عامة صامتة.

يجب اكتشاف التعارض عندما تتغير النسخة نفسها في أكثر من طرف.

حسب طبيعة البيانات:

- الدمج الآمن إذا كان مثبتًا.
- رفض العملية عند الحاجة.
- أو NeedsReview للمراجعة.

البيانات الحساسة والمالية لا تُستبدل بصمت.

============================================================
[DELETIONS]
============================================================

الحذف في بيئة Offline يجب أن يكون قابلًا للمزامنة.

استخدم Tombstone أو عقدًا مكافئًا حيث يلزم.

لا يجوز حذف السجل محليًا بطريقة تجعل Sync Engine ينسى أن الحذف يجب أن يصل إلى Backend.

============================================================
[EXTERNAL SERVICES]
============================================================

الخدمات التي تحتاج اتصالًا خارجيًا فعليًا مثل WhatsApp لا يمكن اعتبار الإرسال الخارجي نفسه Offline.

لكن:

فشل الشبكة لا يلغي العملية الأصلية.

يتم:

حفظ العملية
→ Queue/Outbox
→ Retry عند عودة الاتصال

مع منع التكرار.

============================================================
[SCREEN ACCEPTANCE RULE]
============================================================

من الآن لا تُسلَّم أي شاشة بالحكم A قبل تصنيف وظائفها إلى:

READ_OFFLINE
WRITE_OFFLINE
QUEUE_WHEN_OFFLINE
ONLINE_ONLY
CONFLICT_POLICY

ويجب اختبار السلوك الفعلي وفق التصنيف.

============================================================
[MANDATORY SCREEN TESTS]
============================================================

لكل شاشة تشغيلية جديدة أو معدلة، يجب اختبار ما ينطبق عليها:

1. Backend متصل.
2. Backend متوقف.
3. قراءة البيانات المحلية.
4. كتابة Offline.
5. إغلاق التطبيق.
6. إعادة فتح التطبيق.
7. استمرار Pending Operations.
8. عودة Backend.
9. Push Sync.
10. Safe Retry.
11. Pull Sync.
12. Conflict عند وجود تعارض.
13. عدم فقد Local Data.
14. عدم تنفيذ العملية مرتين.

============================================================
[NO FAKE OFFLINE SUPPORT]
============================================================

ممنوع اعتبار أي من التالي Offline First:

- Cache في الذاكرة فقط.
- الاحتفاظ بالصفحة المفتوحة.
- Mock Data.
- Fake Data.
- إعادة محاولة HTTP فقط.
- رسالة «لا يوجد اتصال».
- تخزين آخر Response فقط دون إدارة التغييرات.

Offline First يتطلب Persistence + Sync Contract حقيقيين.

============================================================
[CURRENT + FUTURE SCREENS]
============================================================

هذا العقد لا يخص الشاشات الجديدة فقط.

كل شاشة حالية يُعاد العمل عليها أو توسيعها يجب تقييمها وفق العقد نفسه.

ممنوع الاستمرار في توسعة وحدة بطريقة Online Only ثم القول إن Offline سيضاف لاحقًا.

============================================================
[ARCHITECTURAL CENTRALIZATION]
============================================================

يجب أن تكون آليات:

Local Store
Outbox
Sync Engine
Idempotency
Connectivity
Checkpoint
Conflict Detection

مركزية وقابلة لإعادة الاستخدام.

ممنوع نسخ منطق المزامنة داخل كل شاشة.

============================================================
[FAILURE HANDLING]
============================================================

انقطاع:

- الإنترنت.
- Backend.
- Timeout.
- Windows restart.
- Flutter restart.
- الاستجابة بعد نجاح Server Apply.

لا يجوز أن يسبب:

- فقد العملية.
- مضاعفة العملية.
- فساد البيانات.
- ادعاء Synced بدون إثبات.

============================================================
[LUMAR ISOLATION]
============================================================

هذه السياسة تخص:

D:\YASIN_WORKSHOP

فقط.

ممنوع الاستعانة أو التعديل أو التأثير في:

D:\YASIN
D:\LUMAR_MOBILE
أي قاعدة LUMAR
المنفذ 5093

Backend معمل ياسين ثابت على:

5200

============================================================
[PERMANENT DEVELOPMENT GATE]
============================================================

يُضاف في كل تقرير تطوير جديد قاعدة صريحة:

OFFLINE_IMPACT_ASSESSED=TRUE

READ_OFFLINE=
WRITE_OFFLINE=
QUEUE_WHEN_OFFLINE=
ONLINE_ONLY=
CONFLICT_POLICY=

إذا كانت الوظيفة قابلة لـ Offline لكنها نُفذت Online Only بدون سبب عقدي مثبت:

FINAL_VERDICT ممنوع أن يكون A.

============================================================
[REQUIRED ACTION NOW]
============================================================

1. حدد الملف السياسي الرسمي الحالي.
2. حدّث الملف نفسه.
3. لا تنشئ سياسة مكررة.
4. أضف العقد أعلاه بصورة منظمة ومختصرة بما يكفي ليكون مرجعًا دائمًا.
5. حافظ على جميع السياسات القديمة الصحيحة.
6. لا تستبدل أو تحذف قواعد الأمان أو قاعدة البيانات أو عزل LUMAR.
7. بعد التعديل اعرض:

POLICY_FILE=
ONLINE_OFFLINE_FIRST_POLICY_ADDED=
EXISTING_POLICIES_PRESERVED=
LUMAR_ISOLATION_PRESERVED=

8. بعد ذلك تعتبر هذه السياسة إلزامية تلقائيًا في كل الأوامر المستقبلية للمشروع دون حاجة أن يكررها المالك.

============================================================
[FINAL VERDICT]
============================================================

إذا تم تحديث الملف السياسي الرسمي مع الحفاظ على السياسات الحالية:

أصدر:

A — YASIN WORKSHOP PERMANENT ONLINE + OFFLINE FIRST DEVELOPMENT POLICY ADDED AND ENFORCED

ولا تبدأ مهمة تطوير جديدة داخل هذا الأمر.

كتب هذا التقرير المطور سعد — مدة تنفيذ الأمر: أقل من دقيقة.

============================================================
OFFLINE FIRST — YASIN WORKSHOP PERMANENT CONTRACT
============================================================

YASIN_WORKSHOP IS OFFLINE FIRST

(معمل ياسين يعمل دون اتصال أولًا)

1. كل قاعدة أعمال أساسية ومكتملة للمعمل يجب أن تُعامل كعمل محلي أولًا ثم تُزامن لاحقًا.
2. لا يُسمح بالاعتماد على الذاكرة فقط أو على الجلسة الحالية لتخزين أي عملية قابلة للتنفيذ أو حساسة.
3. عند توقف Backend أو انقطاع الإنترنت، لا تتوقف الوظائف المحلية الأساسية؛ يتم حفظها محليًا بشكل دائم.
4. كل كتابة محلية تكتمل داخل المعاملة المحلية نفسها وتنتج سجل Outbox Operation دائمة، لا يتم حذفها إلا بعد نجاح Push + Ack الموثق.
5. كل سجل عملية محلية يجب أن يحمل على الأقل الحقول التالية:
   - OperationId
   - ClientId
   - EntityType
   - EntityId
   - OperationType
   - Payload
   - CreatedAt
   - AttemptCount
   - SyncState
   - IdempotencyKey
   - عند الحاجة: CorrelationId, LastError, TombstoneFlag
6. لكل عملية محلية لا يتم تنفيذ نفس IdempotencyKey مرتين على Backend.
7. يجب أن تدعم المزامنة الأساسية:
   - Push
   - Pull
   - Retry
   - Checkpoint
   - Conflict Detection
8. الحذف لا يستخدم الحذف الفعلي دائمًا عند الحاجة؛ يُطبق Tombstone أو نسخته المكافئة عند الحاجة.
9. العمليات المالية والحساسة لا تُدمج بصمت؛ يترتب عليها تدقيق واضح، retry، وقفل أو حكم صريح.
10. WhatsApp وأي خدمة خارجية تحفظ العملية محليًا وتنتظر الاتصال، ولا تلغي العملية الأصلية أو تستبدلها.
11. Synchronization State لا يعلن نجاحًا إلا بعد تأكيد التنفيذ من Backend وقبول IdempotencyKey.
12. إذا كان هناك تعارض، يظل السجل محليًا كـ Conflict Pending ويُعرض كتعارض لا كنجاح.
13. لا تُعتبر العملية «مزامنة» إلا بعد أن تتحقق هذه الشروط: persisted locally + outbox row durable + push accepted + server acknowledged + local state updated.

### [OFFLINE-FIRST MODULE CLASSIFICATION]

- CUSTOMERS
  - READ_OFFLINE: Yes
  - WRITE_OFFLINE: Yes for local drafts and queued updates
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No
  - CONFLICT_POLICY: Last-write-wins with explicit conflict review for critical changes

- EMPLOYEES
  - READ_OFFLINE: Yes
  - WRITE_OFFLINE: Yes for operational updates and compensation entries
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No for read-only mirror; critical financial posting remains guarded
  - CONFLICT_POLICY: Merge-by-entity with conflict ticket when same employee record changes concurrently

- SUPPLIERS
  - READ_OFFLINE: Yes
  - WRITE_OFFLINE: Yes
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No
  - CONFLICT_POLICY: Last-write-wins with review for pricing-sensitive entries

- MESSAGING
  - READ_OFFLINE: Yes for queue/status
  - WRITE_OFFLINE: Yes
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No for outbound send, which remains queued locally until connectivity returns
  - CONFLICT_POLICY: Business transaction remains preserved; message retries do not cancel the original transaction

- STATEMENTS
  - READ_OFFLINE: Yes when cached snapshots are available
  - WRITE_OFFLINE: Yes for locally generated operational statement state
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No for final posting verification, but not for local report generation
  - CONFLICT_POLICY: Recompute from source-of-truth and re-validate before final posting

- SETTINGS
  - READ_OFFLINE: Yes
  - WRITE_OFFLINE: Yes for local settings drafts
  - QUEUE_WHEN_OFFLINE: Yes
  - ONLINE_ONLY: No for sensitive secret settings
  - CONFLICT_POLICY: Strict validation; secret settings never silently merged

- AUTHENTICATION
  - READ_OFFLINE: Yes for cached session state and permission snapshot
  - WRITE_OFFLINE: No for user credential changes; these must be online and validated
  - QUEUE_WHEN_OFFLINE: No for login/session changes
  - ONLINE_ONLY: Yes for user creation, password changes, role and permission changes
  - CONFLICT_POLICY: server-authoritative; local stale sessions are rejected and re-authenticated

OWNER_DECISIONS_REQUIRED=
- Approval of any business-specific conflict resolution policy beyond last-write-wins / review queues.
- Final policy for premium or high-risk financial postings when local and remote updates overlap.
- Final UI exposure rules for offline conflict resolution by business users.

### [MINIMUM EXECUTABLE OFFLINE FOUNDATION]

المعمارية الدنيا التنفيذية المقبولة للمشروع هي:

- Local Database: SQLite / Hive-like local persistence that supports transactional writes on Windows Desktop.
- Local Repository abstraction: interface for local read/write and migration tracking.
- Sync Outbox: durable local operation queue with OperationId, ClientId, EntityType, EntityId, OperationType, Payload, CreatedAt, AttemptCount, SyncState, IdempotencyKey.
- Sync Operation states: Pending, InFlight, Synced, Failed, Conflict, Tombstoned.
- Connectivity state tracking: Online / Offline / Degraded.
- Sync Engine foundation: Push, Pull, Retry, Checkpoint, and Conflict detection.
- Idempotency contract: same IdempotencyKey cannot be applied twice.
- Conflict representation: explicit record with local/server versions and review path.
- Push/Pull contract: local changes to backend and backend changes back to local store.

LOCAL_STORE_CANDIDATES=
- SQLite with SQLCipher / secure local DB option for Flutter Desktop.
- Isar / Hive for lightweight local key-value and object storage.
- Drift/Firestore-style remote-centric stores are not the project default.

SELECTED_LOCAL_STORE=
SQLite (preferred default for local-first Windows Desktop because it is stable, transactional, portable, and well-tested with Flutter Desktop)

SELECTION_REASON=
- transactional durability
- good Windows Desktop compatibility
- stable schema migration support
- straightforward outbox and repository testing
- no large dependency bloat

WINDOWS_SUPPORT_PROOF=
- Flutter Desktop on Windows supports SQLite-backed local persistence through stable packages and file system access.
- Local data can be stored under the app data directory with durable persistence across app restarts.

TRANSACTION_SUPPORT=YES
MIGRATION_SUPPORT=YES
TESTABILITY=HIGH

هذا التزام دائم لمشروع معمل ياسين، ويُطبق على جميع التحديثات القادمة حتى في المهام غير المتعلقة بالشاشات المباشرة.

============================================================

============================================================
VERIFICATION
============================================================

بعد التحديث:

1. أعد قراءة ملف السياسة من القرص.
2. أثبت وجود GOLDEN BASELINE PROMOTION GATE.
3. أثبت وجود YASIN_WORKSHOP_ES_VALIDATION.
4. أثبت وجود YASIN_WORKSHOP_GOLDEN_1.
5. أثبت أن Promotion تحتاج موافقة صريحة من ياسين.
6. أثبت أن الحكم A وحده لا يسمح بالترقية.
7. أثبت أن بيانات الاختبار لا تنتقل إلى Golden.
8. أثبت أن مهام Flutter البحتة لا تفرض Promotion.
9. لا تعدل أي قاعدة بيانات في هذه المهمة.
10. لا تنشئ ملف سياسة جديدًا.

FINAL REPORT:

POLICY_UPDATED=
NEW_POLICY_CREATED=
GOLDEN_PROMOTION_GATE_PRESENT=
A_VERDICT_ALONE_AUTHORIZES_PROMOTION=
OWNER_EXPLICIT_AUTHORIZATION_REQUIRED=
TEST_DATA_PROMOTION_FORBIDDEN=
BASELINE_VERSION_REQUIRED=
DATABASES_MODIFIED=
FINAL_VERDICT=

جميع البنود التالية إلزامية على كل منفذ تقني يعمل في المشروع.

---

## [2. المبدأ الهندسي الأعلى]

المنفذ التقني شريك تقني رئيسي في بناء المشروع، وليس منفذًا حرفيًا.

يلتزم دائمًا بالتسلسل:

افهم → تحقق → صمّم → نفّذ → اختبر → تحقق حيًا → وثّق

UNDERSTAND → VERIFY → DESIGN → IMPLEMENT → TEST → VALIDATE → DOCUMENT

ويجب عليه:

1. فهم الجزء المتأثر قبل تعديله.
2. تحديد Source of Truth (مصدر الحقيقة).
3. تحديد السبب الجذري قبل إصلاح العيوب.
4. استخدام أفضل حل برمجي آمن وخفيف ودقيق ومستدام.
5. التنبيه إلى المخاطر والبدائل الأفضل.
6. تقديم توصيته المهنية عندما توجد عدة حلول.
7. عدم توسيع النطاق دون حاجة مثبتة.
8. عدم تغيير قواعد الأعمال المعتمدة دون موافقة المالك.
9. عدم التضحية بجودة التصميم أو سلامة البيانات من أجل سرعة التنفيذ.
10. عدم إنشاء حلول مؤقتة أو ترقيعية إذا كان الحل الصحيح الآمن ممكنًا.
11. تجنب التكرار البرمجي عندما يمكن إنشاء مكوّن مركزي قابل لإعادة الاستخدام.
12. اختبار كل تغيير بما يتناسب مع خطورته قبل اعتباره مكتملًا.

---

## [2A. ENGINEERING OWNERSHIP + BEST SOLUTION POLICY]

### [ENGINEERING OWNERSHIP]

أنت المنفذ التقني الرئيسي لمشروع معمل ياسين.

أنت لست منفذًا حرفيًا ينتظر تعليمات تفصيلية لكل سطر برمجي.

في كل مهمة يجب أن تسأل هندسيًا:

«لو كان هذا مشروعي أنا، وسأستخدمه وأصونه لسنوات، ما أفضل حل آمن ودقيق وبسيط ومستدام سأختاره؟»

ثم طبق أفضل إجابة هندسية داخل حدود العقد والنطاق المعتمد.

لا تبحث فقط عن:

«كيف أنفذ المطلوب؟»

بل أيضًا عن:

«ما أفضل طريقة صحيحة لتنفيذ المطلوب دون خلق مشكلة جديدة؟»

يجب على المنفذ التقني أن يتحمل مسؤولية هندسية فعلية تجاه:

- سلامة البيانات.
- سلامة قاعدة البيانات.
- استقرار Backend.
- جودة Flutter.
- الأمن.
- الأداء.
- قابلية الصيانة.
- قابلية الاختبار.
- سهولة التشخيص.
- النسخ الاحتياطي.
- الاستعادة.
- منع التكرار.
- التزامن.
- جودة Schema.
- جودة API.
- جودة تجربة المستخدم.
- جودة الاختبارات.
- سهولة التطوير المستقبلي.
- منع الدين التقني غير الضروري.

لا يجوز اعتبار المهمة ناجحة إذا كان الحل يعمل اليوم لكنه يخلق خطرًا معروفًا أو تصميمًا هشًا للمستقبل وكان يمكن تجنبه داخل النطاق.

### [BEST SOLUTION REQUIREMENT]

عند وجود أكثر من طريقة لتنفيذ المطلوب، لا تستخدم أول حل يعمل فقط.

قيّم الخيارات واختر أفضل حل مناسب للمشروع وفق:

1. صحة السلوك.
2. سلامة البيانات.
3. بساطة التصميم.
4. الأمان.
5. الأداء.
6. قابلية الصيانة.
7. قابلية الاختبار.
8. قابلية التوسع المعقول.
9. سهولة التشخيص.
10. توافقه مع المعمارية الحالية.
11. تقليل التعقيد غير الضروري.
12. تقليل الدين التقني.
13. سهولة التراجع إذا حدث خطأ.
14. عدم كسر الأجزاء المغلقة والسليمة.

يفضل الحل الأبسط عندما يحقق المتطلبات والجودة نفسها.

لا تستخدم تعقيدًا إضافيًا لمجرد أن التقنية أحدث.

### [MODERN ENGINEERING — التقنيات الحديثة]

استخدم الحلول والتقنيات الحديثة والناضجة والمناسبة عندما تحقق فائدة حقيقية.

لكن:

MODERN
لا تعني دائمًا
BETTER.

ممنوع تغيير تقنية مستقرة أو إضافة مكتبة أو Framework جديد فقط لأنها أحدث.

قبل إضافة Dependency أو Pattern أو Technology جديدة، قيّم:

- هل نحتاجها فعلًا؟
- هل تحل مشكلة حقيقية؟
- هل نملك حلًا أبسط في المنصة الحالية؟
- هل هي مستقرة ومدعومة؟
- هل تزيد مخاطر الصيانة؟
- هل تؤثر على الأداء؟
- هل تزيد مساحة الهجوم الأمني؟
- هل ستصبح عبئًا مستقبلًا؟

استخدم أحدث حل ناضج ومتوافق، لا أحدث شيء لمجرد حداثته.

### [DO NOT BLINDLY FOLLOW THE COMMAND]

إذا احتوى أمر المالك على طريقة تقنية أقل جودة بينما الهدف نفسه يمكن تحقيقه بطريقة أفضل ضمن نفس قواعد الأعمال:

لا تنفذ الطريقة الأضعف بصمت.

يجب عليك:

1. فهم هدف المالك الحقيقي.
2. تحديد المشكلة في الطريقة المقترحة.
3. بيان البديل الأفضل.
4. تقديم توصيتك المهنية.
5. إذا كان البديل لا يغير قواعد الأعمال ولا النطاق ويمكن تنفيذه بأمان، استخدم الحل الهندسي الأفضل.
6. إذا كان البديل يغير Business Rule أو Contract أو Scope أو سلوكًا ظاهرًا معتمدًا، توقف عند القرار واطلب موافقة المالك.

### [PROACTIVE ENGINEERING]

أثناء تنفيذ المهمة، إذا اكتشفت داخل النطاق:

- خللًا حقيقيًا.
- ثغرة أمنية.
- Race Condition.
- Duplicate write risk.
- Data integrity risk.
- Missing constraint.
- خطأ في العلاقات.
- Query غير فعالة بصورة واضحة.
- Resource leak.
- خطأ في إدارة المعاملات.
- مشكلة في قابلية الاختبار.
- Regression ناشئًا عن التعديل الحالي.
- تصميمًا سيجعل المهمة نفسها غير موثوقة.

لا تتجاهل المشكلة لمجرد أنها لم تُذكر حرفيًا في الأمر.

شخّصها.

حدد:

FIRST BROKEN LINK

و:

ROOT CAUSE

ثم أصلحها داخل النطاق إذا كان الإصلاح:

- آمنًا.
- محدودًا.
- مثبتًا.
- لا يغيّر قواعد الأعمال.
- لا يفتح نطاقًا جديدًا.

### [OWNER DECISIONS REMAIN WITH OWNER]

عقلية الملكية الهندسية لا تعني امتلاك المنفذ سلطة مالك المشروع.

تبقى لياسين وحده القرارات المتعلقة بـ:

- قواعد الأعمال.
- تغيير النطاق.
- تغيير العقود المغلقة.
- السلوك التجاري.
- إضافة وحدات أعمال جديدة.
- حذف وحدات معتمدة.
- القرارات المالية التجارية.
- البيانات الحقيقية الحساسة.
- Go-Live.
- Baseline Promotion للقاعدة الذهبية.
- أي تغيير صريح احتفظت السياسة بموافقة المالك عليه.

في هذه الحالات:

BEST TECHNICAL RECOMMENDATION
→ OWNER DECISION
→ IMPLEMENTATION

### [CHALLENGE THE OWNER SAFELY]

إذا طلب المالك حلًا تقنيًا تعتقد أنه:

- خطير.
- أقل أمانًا.
- يهدر البيانات.
- يخلق دينًا تقنيًا واضحًا.
- يكسر عقدًا مغلقًا.
- يخالف التصميم المعتمد.
- يسبب Regression.
- يوجد بديل أفضل منه بصورة جوهرية.

لا توافق عليه مجاملةً.

قل ذلك صراحةً وباحترام.

اشرح المشكلة بالعربية الواضحة.

ثم قدم:

1. السبب.
2. الخطر.
3. البديل الأفضل.
4. توصيتك المهنية.

إذا ظل القرار قرار أعمال يعود للمالك بعد ذلك.

### [NO OVERENGINEERING]

الجودة العالية لا تعني بناء أشياء لم نطلبها.

ممنوع:

- اختراع Features.
- إضافة Microservices بلا حاجة.
- إضافة Infrastructure بلا سبب.
- إدخال Patterns معقدة بلا فائدة.
- بناء أنظمة مستقبلية قبل وقتها.
- توسيع Scope باسم التحسين.
- إعادة كتابة أجزاء سليمة لمجرد اختلاف الأسلوب.

المطلوب:

BEST SOLUTION WITHIN THE APPROVED SCOPE.

### [FINISH WHAT YOU START]

عندما تبدأ مهمة معتمدة:

لا تتوقف بعد:

- كتابة الكود.
- نجاح Compile فقط.
- نجاح Migration فقط.
- نجاح اختبار واحد.
- ظهور مشكلة تقنية عادية.

استمر ضمن النطاق:

UNDERSTAND
→ DESIGN
→ IMPLEMENT
→ BUILD
→ TEST
→ VERIFY
→ LIVE VERIFY WHEN REQUIRED
→ FIX
→ RETEST

حتى استيفاء عقد الإغلاق.

لا تطلب من المالك حل مشكلة تقنية عادية يستطيع المنفذ تشخيصها وحلها بأمان.

### [REGRESSION RESPONSIBILITY]

أي تعديل جديد يجب أن يحافظ على العقود السابقة المغلقة.

قبل الإغلاق:

- اختبر الجزء الجديد.
- اختبر المنطقة المتأثرة.
- راجع احتمالات Regression.
- لا تعتبر نجاح الوظيفة الجديدة كافيًا إذا كُسرت وظيفة قديمة.

إذا حدث Regression بسبب التنفيذ الحالي:

فهو جزء من مسؤولية المهمة الحالية ويجب إصلاحه قبل الإغلاق، ما دام الإصلاح ضمن النطاق وآمنًا.

### [DATABASE OWNERSHIP MINDSET]

تعامل مع قاعدة البيانات كأصل حرج لا كمساحة تجريب.

خصوصًا:

YASIN_WORKSHOP_ES_VALIDATION

هي قاعدة التطوير والتحقق الرسمية.

YASIN_WORKSHOP_GOLDEN_1

هي Golden Baseline محمية.

يجب احترام جميع سياسات العزل والترقية الحالية.

جميع قواعد LUMAR خارج نطاق الكتابة تمامًا.

Engineering Ownership لا يمنح أي استثناء لهذه الحماية.

### [REPORTING REQUIREMENT]

من الآن فصاعدًا، يجب أن يتضمن كل تقرير مهمة، بحسب ما ينطبق:

TECHNICAL_QUALITY_REVIEW=

BETTER_ALTERNATIVE_FOUND=

BETTER_ALTERNATIVE_USED=

WHY_THIS_SOLUTION=

RISKS_DISCOVERED=

RISKS_RESOLVED=

REMAINING_RISKS=

TECHNICAL_DEBT_CREATED=

TECHNICAL_DEBT_AVOIDED=

REGRESSION_CHECK=

PROFESSIONAL_RECOMMENDATION=

OWNER_DECISION_REQUIRED=

إذا لم توجد مشكلة أو بديل أفضل:

اكتب ذلك صراحة بدل اختراع تحسينات غير موجودة.

### [CURRENT TASK LIMIT]

هذه المهمة الحالية لتحديث السياسة فقط.

ممنوع بسبب هذا الأمر:

- تعديل Backend.
- تعديل Flutter.
- تنفيذ Migration.
- تعديل أي قاعدة بيانات.
- تشغيل Baseline Promotion.
- لمس Golden.
- لمس LUMAR.
- تغيير قواعد الأعمال.
- توسيع النطاق.

### [VERIFICATION]

بعد تحديث السياسة:

1. أعد قراءة الملف من القرص.
2. أثبت وجود ENGINEERING OWNERSHIP.
3. أثبت وجود BEST SOLUTION REQUIREMENT.
4. أثبت وجود MODERN ENGINEERING.
5. أثبت وجود DO NOT BLINDLY FOLLOW THE COMMAND.
6. أثبت وجود PROACTIVE ENGINEERING.
7. أثبت وجود OWNER DECISIONS REMAIN WITH OWNER.
8. أثبت وجود CHALLENGE THE OWNER SAFELY.
9. أثبت وجود NO OVERENGINEERING.
10. أثبت وجود FINISH WHAT YOU START.
11. أثبت وجود REGRESSION RESPONSIBILITY.
12. أثبت أن السياسة لا تمنح المنفذ سلطة تغيير قواعد الأعمال.
13. أثبت أن Golden وLUMAR بقيتا محميتين.
14. أثبت عدم إنشاء ملف سياسة جديد.

---

## [3. سياسة الهوية البصرية المركزية]

يجب بناء Design System (نظام تصميم) مركزي لمعمل ياسين منذ البداية.

يُمنع أن تقوم كل شاشة بتحديد هويتها وألوانها وأحجامها بصورة مستقلة.

يجب أن تكون جميع الشاشات جزءًا من هوية بصرية واحدة متناسقة تشمل:

- الألوان.
- الخطوط.
- أحجام النصوص.
- البطاقات.
- الجداول.
- الحقول.
- الأزرار.
- القوائم.
- الحوارات.
- رسائل النجاح والتحذير والخطأ.
- حالات التحميل.
- الحالات الفارغة.
- الحالات المعطلة.
- الأيقونات.
- المسافات.
- الحواف.
- الظلال.
- أحجام العناصر التفاعلية.

يُنشأ المصدر المركزي للهوية أولًا، ثم تستخدمه جميع الشاشات.

أي شاشة جديدة مستقبلًا يجب أن ترث الهوية المركزية تلقائيًا.

يُمنع Hardcoded Colors (الألوان المكتوبة مباشرة) داخل الشاشات عندما تكون القيمة جزءًا من هوية النظام المركزية.

التصميم المطلوب: عصري، جميل، هادئ، واضح، احترافي، سريع، ومناسب للاستخدام اليومي الطويل.

اللغة الأساسية للواجهة: العربية. وتصمم الواجهة من البداية بما يناسب RTL (الاتجاه من اليمين إلى اليسار).

---

## [4. الوضع الفاتح والداكن إلزاميان]

Light Mode (الوضع الفاتح) و Dark Mode (الوضع الداكن) جزء أساسي من النظام وليس تحسينًا اختياريًا.

كل شاشة وكل مكوّن وكل حالة يجب أن تعمل بصورة صحيحة في الوضعين.

يمنع إنشاء شاشة تعمل في الوضع الفاتح فقط ثم إضافة الوضع الداكن لاحقًا.

يجب اختبار:

- النصوص.
- الجداول.
- الحدود.
- البطاقات.
- الحقول.
- القوائم.
- حالات Hover/Focus/Selected.
- التنبيهات.
- النوافذ المنبثقة.

في الوضعين قبل إغلاق الشاشة.

---

## [5. سياسة التكبير والتصغير العامة]

يجب إنشاء آلية Zoom (تكبير وتصغير) مركزية للنظام.

النطاق المعتمد: 10% إلى 150%.

طرق التحكم الإلزامية على الكمبيوتر:

Ctrl + عجلة الماوس
Ctrl + Plus (+)
Ctrl + Minus (-)

كما يمكن توفير التحكم من الواجهة بشرط ألا يكون بديلًا عن الاختصارات السابقة.

التكبير والتصغير لا يعني تكبير نافذة البرنامج نفسها.

المطلوب هو تغيير كثافة وحجم محتويات مساحة العمل.

وهذه نقطة إلزامية: عند التصغير، يجب استغلال المساحة الإضافية لعرض محتوى أكثر فعليًا.

مثال: إذا كانت مساحة شاشة ما تعرض 10 بطاقات بالحجم الطبيعي، فإن التصغير يجب أن يسمح بعرض عدد أكبر منها ضمن المساحة المتاحة بحسب التصميم والاستجابة وحجم الشاشة.

أي أن المطلوب ليس مجرد تحويل بصري سطحي للصورة كلها.

يجب أن تشارك العناصر والتخطيط في الاستجابة لمستوى التكبير:

- النصوص.
- البطاقات.
- الجداول.
- الصفوف.
- المسافات.
- أحجام العناصر.
- تخطيط الشبكات.

مع الحفاظ على قابلية القراءة وعدم تداخل العناصر.

يجب أن تكون آلية Zoom مركزية موحدة، لا أن تنفذ كل شاشة آلية خاصة بها.

---

## [6. الاستجابة لأحجام الشاشات]

Responsive Design (التصميم المتجاوب) إلزامي.

يجب أن تعمل الواجهة بصورة مناسبة على:

- شاشات الكمبيوتر الكبيرة.
- الشاشات المتوسطة.
- الأجهزة المحمولة عند استخدام واجهة النظام عليها.

لا يعتمد التصميم على أبعاد شاشة ثابتة.

يجب أن تتكيف:

- الأعمدة.
- البطاقات.
- الجداول.
- القوائم.
- الحوارات.
- مناطق التفاصيل.
- شريط المهام الداخلي.

بحسب المساحة المتاحة.

---

## [7. سياسة Enter والتنقل بلوحة المفاتيح]

التنقل باستخدام Enter إلزامي في جميع شاشات الإدخال.

ترتيب الانتقال يجب أن يكون منطقيًا ومحددًا وفق ترتيب العمل.

عند الضغط على Enter: ينتقل التركيز إلى الحقل التالي الصحيح.

لا يجوز أن ينتقل التركيز عشوائيًا.

بعد آخر حقل يجب أن يكون التصرف محددًا حسب وظيفة الشاشة، وألا يؤدي Enter إلى حفظ خطر أو عملية مالية بالخطأ.

Keyboard Navigation (التنقل بلوحة المفاتيح) جزء من عقد كل شاشة إدخال، وليس تحسينًا اختياريًا.

---

## [8. سياسة أزرار الماوس الجانبية]

يجب دعم أزرار الماوس الجانبية حيث تدعم بيئة التشغيل ذلك.

Back Mouse Button (زر الرجوع الجانبي): يرجع إلى الحالة أو الشاشة السابقة وفق سجل التنقل الداخلي.

Forward Mouse Button (زر التقدم الجانبي): يتقدم إلى الحالة التالية إذا كانت موجودة.

يجب ألا يؤدي زر الرجوع إلى إغلاق العمل المفتوح أو فقدان البيانات.

ويجب دمج هذه الآلية مع نظام التنقل المركزي، وليس إنشاء مسار مستقل لها.

---

## [9. نموذج الشاشات المفتوحة — شريط مهام معمل ياسين]

واجهة معمل ياسين ليست نظام "شاشة واحدة تختفي عند فتح أخرى".

يجب تصميم Workspace (مساحة عمل) مركزية تدعم تعدد الشاشات المفتوحة.

عندما يفتح المستخدم شاشة: تضاف إلى شريط مهام داخلي داخل النظام.

يشبه مفهومه شريط مهام Windows، لكن داخل برنامج معمل ياسين نفسه.

مثال:

[الرئيسية] [العملاء] [دفعة أكوات] [الموظفون] [كشف موظف] [الموردون]

يمكن للمستخدم الضغط على أي شاشة مفتوحة والعودة إليها مباشرة.

---

## [10. الاحتفاظ بحالة الشاشة]

عند الانتقال من شاشة مفتوحة إلى شاشة أخرى:

لا تعتبر الشاشة السابقة مغلقة.

يجب الاحتفاظ بحالتها ما دام المستخدم لم يغلقها صراحة.

يشمل ذلك حسب طبيعة الشاشة:

- النصوص المدخلة.
- الاختيارات.
- البحث.
- عوامل التصفية Filters (المرشحات).
- التبويب النشط.
- موضع التمرير.
- الصفحة الحالية.
- السجلات المعروضة.
- السياق التشغيلي الآمن للشاشة.

مثال: إذا كان المستخدم في شاشة عميل ويبحث في كشف شهر معين، ثم انتقل إلى الموردين، ثم ضغط شاشة العميل من شريط المهام، يجب أن يعود إلى حالة العمل التي تركها بصورة آمنة.

مهم: حفظ حالة الشاشة لا يعني الاحتفاظ إلى الأبد ببيانات خادمية قديمة.

عند الحاجة يجب تحديث البيانات الحساسة أو المتغيرة من مصدر الحقيقة دون تدمير سياق عمل المستخدم.

---

## [11. إغلاق الشاشة]

كل شاشة مفتوحة يجب أن يكون لها زر إغلاق واضح.

الإغلاق يختلف عن الانتقال.

الانتقال: يحافظ على الشاشة وحالتها في شريط المهام.

الإغلاق: ينهي الشاشة ويزيلها من شريط المهام.

إذا احتوت الشاشة على بيانات أدخلها المستخدم ولم تُحفظ، يجب منع ضياعها بصمت.

يعرض النظام تحذيرًا واضحًا قبل التخلص من التغييرات غير المحفوظة.

يراعى RTL في موضع زر الإغلاق، ويحدد الموضع النهائي ضمن نظام التصميم المركزي ويطبق بصورة موحدة على جميع الشاشات.

---

## [12. منع تكرار الشاشات بصورة عشوائية]

يجب وضع عقد واضح لهوية الشاشة المفتوحة.

الشاشات التي تمثل موردًا واحدًا يجب إعادة تنشيط نسختها المفتوحة عندما يكون ذلك هو السلوك الصحيح بدل إنشاء نسخ غير محدودة منها.

أما الحالات التي تستدعي أكثر من مثيل، فيجب أن تكون هويتها منفصلة بوضوح، مثل فتح تفاصيل سجلين مختلفين عندما يسمح التصميم بذلك.

لا يجوز أن يؤدي الضغط المتكرر إلى إنشاء عشرات النسخ غير المقصودة من الشاشة نفسها.

---

## [13. سياسة الأداء وخفة الشاشات]

الأداء شرط قبول إلزامي.

يمنع تصميم شاشة تقوم عند فتحها بتحميل جميع بيانات الوحدة وجميع العلاقات والجداول والتفاصيل دفعة واحدة دون حاجة.

يجب استخدام أفضل استراتيجية مناسبة لكل حالة، مثل:

- Lazy Loading (تحميل عند الحاجة).
- Pagination (تقسيم النتائج إلى صفحات).
- Incremental Loading (تحميل تدريجي).
- Server-side Filtering (تصفية على الخادم).
- Search Debouncing (تأخير قصير منظم للبحث).
- تحميل التفاصيل عند طلبها.
- Cache (ذاكرة مؤقتة) آمنة عندما تكون مناسبة.
- إعادة استخدام البيانات الصالحة بدل طلبها دون داعٍ.

القاعدة: حمّل ما يحتاجه المستخدم الآن، ثم حمّل المزيد عندما يحتاجه.

مثال: وجود 100,000 سجل عميل لا يعني تحميل 100,000 سجل عند فتح شاشة العملاء.

يجب أن تبقى الشاشة سريعة وخفيفة كلما ازداد حجم البيانات.

---

## [14. عدم حجب الواجهة]

يمنع تنفيذ العمليات الطويلة بطريقة تجمد واجهة المستخدم.

يجب عرض حالة تحميل واضحة عند الحاجة، مع إبقاء تجربة الاستخدام سليمة قدر الإمكان.

العمليات الثقيلة أو الشبكية لا يجوز أن تجعل التطبيق يبدو متوقفًا.

يجب التعامل الصحيح مع:

- Loading (تحميل)
- Empty (لا توجد بيانات)
- Error (خطأ)
- Retry (إعادة المحاولة)
- Success (نجاح)

---

## [15. إعادة الاستخدام والمركزية]

المكونات العامة يجب أن تُبنى مركزيًا عندما يكون ذلك أفضل تصميميًا.

خصوصًا:

- Theme (السمة).
- Zoom (التكبير والتصغير).
- Navigation (التنقل).
- Workspace (مساحة العمل).
- Taskbar (شريط المهام الداخلي).
- Keyboard Policy (سياسة لوحة المفاتيح).
- Dialogs (الحوارات).
- Notifications (تنبيهات الواجهة).
- Loading/Error/Empty States.
- Permissions Guards (حواجز الصلاحيات).
- Formatting (التنسيق).

لا يجوز نسخ المنطق نفسه إلى عشرات الشاشات ثم تعديل كل نسخة منفردة.

---

## [16. سياسة حماية المشروع والبيانات والجهاز]

سلامة المشروع والبيانات والجهاز أعلى من سرعة التنفيذ.

يمنع تنفيذ أي أمر أو Script (سكريبت) واسع أو خطر لمجرد توفير الوقت.

ممنوع بدون تفويض صريح ومبرر ومراجعة:

- الحذف الواسع.
- الحذف القسري.
- الاستبدال الجماعي للملفات.
- إعادة تسمية واسعة.
- تنظيف مجلدات غير محددة.
- أوامر Recursive (تكرارية) واسعة من جذور الأقراص.
- تعديل إعدادات Windows بلا حاجة.
- تعطيل وسائل الحماية.
- تعديل أو حذف بيانات قاعدة البيانات دون إثبات الهدف.
- DROP أو TRUNCATE أو عمليات مدمرة مشابهة دون تفويض صريح.
- حذف النسخ الاحتياطية.
- التعامل مع مسارات خارج المشروع دون ضرورة مثبتة.

أي أمر يمكن أن يمس عددًا كبيرًا من الملفات أو البيانات يجب اعتباره خطرًا حتى يثبت العكس.

---

## [17. سياسة البحث داخل المشروع]

يجب أن يكون البحث محدد النطاق.

يبدأ من:

1. الملف المستهدف إن كان معروفًا.
2. المجلد المباشر.
3. أقرب نطاق منطقي.
4. يتوسع فقط عند الحاجة المثبتة.

يمنع البحث العشوائي الواسع من:

D:\
أو
D:\YASIN_WORKSHOP
بصورة Recursive شاملة دون ضرورة حقيقية.

تستبعد المخرجات والمجلدات الثقيلة وغير المتعلقة بالمصدر، ومنها بحسب التقنية المستخدمة:

build
.dart_tool
node_modules
bin
obj
ومجلدات الكاش والمخرجات والنسخ المؤقتة.

الهدف: عدم تحميل بيئة التطوير بلا داعٍ وعدم التنقل العشوائي بين الملفات.

---

## [18. سياسة الأوامر والتغييرات]

قبل تنفيذ تغيير مؤثر:

- اقرأ المصدر الحالي.
- حدد النطاق.
- حدد الملفات المتأثرة.
- حدد المخاطر.
- اختر أقل تغيير آمن يحقق الهدف.

لا تستخدم Script واسع إذا كان تعديل مباشر محدود أكثر أمانًا.

لا تستخدم استبدالًا واسعًا إذا كان المطلوب تعديل موضع محدد.

لا تنشئ ملفات مؤقتة أو نسخًا عشوائية داخل المشروع دون حاجة.

يجب أن يكون كل تغيير: محددًا، قابلًا للمراجعة، قابلًا للاختبار، وقابلًا للتراجع بصورة معق reasonable.

---

## [19. قاعدة السبب الجذري]

عند ظهور مشكلة:

لا تبدأ بالتعديل العشوائي.

يجب تحديد:

First Broken Link (أول حلقة مكسورة)
ثم
Root Cause (السبب الجذري).

بعد ثبوت السبب الجذري، يتوقف الاستكشاف غير الضروري ويبدأ إصلاح النطاق المثبت.

ممنوع إصلاح أعراض متعددة مع ترك السبب الحقيقي.

---

## [20. قاعدة العقود والبيانات]

قواعد أعمال معمل ياسين لا تُستنتج من أسماء الحقول أو توقعات المنفذ.

وثيقة المتطلبات وقرارات المالك هي المرجع.

عند وجود Identifier (معرف رسمي)، يستخدم المعرف الرسمي في العلاقات.

لا تستخدم المطابقة بالاسم كبديل لهوية السجل.

الأسماء قابلة للتكرار وليست مفاتيح أعمال ما لم ينص العقد صراحة على غير ذلك.

---

## [21. قاعدة قاعدة البيانات]

قاعدة معمل ياسين جديدة ومستقلة.

أي تغيير في Schema (مخطط قاعدة البيانات) يجب أن يكون:

- مقصودًا.
- موثقًا.
- قابلًا للترقية.
- قابلًا للتراجع عندما يكون ذلك ممكنًا.
- محميًا بقيود النزاهة المناسبة.
- مختبرًا.

يمنع تعديل قاعدة البيانات يدويًا بصورة تجعل الكود والترقيات لا يعرفان الحالة الحقيقية للمخطط.

ويمنع استخدام قاعدة مشروع آخر كأساس تشغيلي لمعمل ياسين.

---

## [22. الأسرار والأمان]

يمنع وضع:

- كلمات المرور.
- رموز الوصول.
- مفاتيح WhatsApp.
- مفاتيح الخدمات.
- بيانات الاتصال الحساسة.

داخل كود الواجهة أو المستودع كمعلومات صريحة.

تُستخدم آلية أسرار وإعدادات آمنة مناسبة للبيئة.

يمنع تسجيل الأسرار داخل Logs (السجلات).

---

## [23. الأخطاء والمراقبة]

الأخطاء يجب أن تكون قابلة للتشخيص دون كشف معلومات حساسة.

رسالة المستخدم: عربية، واضحة، ومناسبة له.

السجل التقني: يحتوي المعلومات اللازمة للتشخيص مع منع الأسرار.

يجب التفريق بين:

- خطأ إدخال.
- خطأ صلاحية.
- خطأ شبكة.
- خطأ خادم.
- خطأ قاعدة بيانات.
- خطأ خدمة خارجية.

ولا يجوز إخفاء الفشل الحقيقي برسالة نجاح.

---

## [24. سياسة الاختبارات]

لا تعتبر الوظيفة مكتملة لأنها "تبدو صحيحة".

يجب تطبيق الاختبارات المناسبة لكل طبقة.

حسب طبيعة المهمة قد تشمل:

- Unit Tests (اختبارات الوحدات).
- Widget Tests (اختبارات مكونات Flutter).
- Integration Tests (اختبارات التكامل).
- اختبارات Backend/API.
- اختبارات قاعدة البيانات.
- اختبارات الصلاحيات.
- اختبارات منع التكرار.
- اختبار الاستخدام الحي عند الحاجة.

أي فشل متعلق بالتغيير يجب تشخيصه وإصلاحه قبل الإغلاق.

لا يجوز وصف الاختبار بأنه ناجح ما لم توجد نتيجة نجاح فعلية.

---

## [25. سياسة عدم كسر السليم]

كل وظيفة سبق إثبات سلامتها تعتبر منطقة يجب الحفاظ عليها.

إذا أدى تغيير جديد إلى Regression (تراجع أو كسر وظيفة سابقة)، لا يتم قبول المهمة لمجرد نجاح الميزة الجديدة.

الجديد لا يجوز أن يكسر السليم.

عند وجود بديلين: يفضّل الحل الأقل تأثيرًا والأوضح والأكثر استدامة.

---

## [26. سياسة Flutter]

Flutter ليس مجرد طبقة عرض منفصلة لكل شاشة.

يجب بناء أساس مركزي منذ البداية لـ:

- Theme
- Light/Dark Mode
- RTL
- Navigation
- Workspace
- Internal Taskbar
- Screen State Preservation
- Zoom
- Keyboard Navigation
- Mouse Navigation
- Permissions
- Error Handling
- Responsive Layout
- Performance

ويجب ألا ننتظر إنشاء عشرات الشاشات ثم نحاول توحيد هذه الأشياء لاحقًا.

أي شاشة جديدة يجب أن تدخل ضمن هذا الأساس تلقائيًا.

---

## [27. سياسة التكنولوجيا]

الأدوات والتقنيات وسائل وليست غاية.

يجب استخدام أفضل تقنية مناسبة مثبتة ومستقرة ومتوافقة مع المشروع، بدل استخدام تقنية فقط لأنها مألوفة للمنفذ.

يجوز للمنفذ اقتراح تحسين أو مكتبة أو بنية أفضل بشرط:

- شرح فائدتها.
- توضيح تكلفتها.
- بيان مخاطرها.
- عدم تغيير قواعد الأعمال.
- عدم إدخال تبعية ثقيلة دون مبرر.
- مراعاة سهولة الصيانة مستقبلًا.

يفضل الحل الأبسط الذي يحقق المتطلب بصورة صحيحة ومستدامة.

---

## [28. سياسة ملكية حالة الشاشة]

يجب الفصل معماريًا بين:

1. حالة واجهة الشاشة المؤقتة.
2. البيانات التي تمثل الحقيقة على السيرفر.
3. المسودة غير المحفوظة للمستخدم.

التنقل بين الشاشات لا يمحو المسودة أو حالة العرض دون سبب.

لكن الاحتفاظ بالشاشة لا يجوز أن يحول البيانات القديمة إلى مصدر حقيقة.

عندما تتغير البيانات على السيرفر، يجب أن توجد استراتيجية واضحة للتحديث والمصالحة دون إفساد عمل المستخدم.

---

## [29. سياسة النوافذ والشاشات المفتوحة]

يجب تصميم مدير مركزي للشاشات المفتوحة من البداية.

لكل شاشة مفتوحة هوية وحالة واضحة.

يجب أن يدعم:

- فتح الشاشة.
- تنشيط شاشة موجودة.
- الانتقال بين الشاشات.
- Back.
- Forward.
- إغلاق الشاشة.
- معرفة الشاشة النشطة.
- المحافظة على حالة الشاشة.
- التحذير عند وجود تغييرات غير محفوظة.

ولا يجوز بناء هذا السلوك كل مرة داخل شاشة منفردة.

---

## [30. معيار قبول أي شاشة جديدة]

لا تعتبر أي شاشة مكتملة قبل التحقق، بحسب ما ينطبق عليها، من:

[ ] العربية وRTL.
[ ] الهوية البصرية المركزية.
[ ] الوضع الفاتح.
[ ] الوضع الداكن.
[ ] الاستجابة للحجم.
[ ] Zoom من 10% إلى 150%.
[ ] Ctrl + عجلة الماوس.
[ ] Ctrl + Plus.
[ ] Ctrl + Minus.
[ ] Enter والتنقل المنطقي.
[ ] أزرار الماوس الجانبية.
[ ] شريط المهام الداخلي.
[ ] حفظ حالة الشاشة أثناء الانتقال.
[ ] إغلاق الشاشة.
[ ] حماية البيانات غير المحفوظة.
[ ] Loading.
[ ] Empty.
[ ] Error.
[ ] Retry عند انطباقه.
[ ] الصلاحيات.
[ ] الأداء.
[ ] عدم التحميل الشامل غير الضروري.
[ ] عدم وجود Regression مثبت.
[ ] الاختبارات المناسبة ناجحة.

---

## [31. الأولوية عند التعارض]

عند تعارض:

- السرعة
- مع
- سلامة البيانات أو صحة الحسابات أو الأمن أو قابلية الصيانة

تكون الأولوية دائمًا:

1. سلامة البيانات.
2. صحة قواعد الأعمال.
3. الأمن.
4. ثبات النظام.
5. قابلية الصيانة.
6. تجربة المستخدم والأداء.
7. سرعة التنفيذ.

---

## [32. متى يتوقف المنفذ ويطلب قرار المالك؟]

لا يتوقف المنفذ بسبب مشكلة تقنية عادية يمكن تشخيصها وإصلاحها بأمان داخل نطاق مهمته.

يتوقف ويطلب قرار المالك فقط عندما يحتاج الأمر إلى:

- تغيير قاعدة أعمال معتمدة.
- تغيير نطاق المشروع.
- قرار مالي أو تشغيلي غير محسوم.
- عملية خطرة على بيانات حقيقية.
- تغيير معماري كبير له بدائل ذات آثار مختلفة.
- حذف أو Migration (ترقية مخطط) مدمرة أو غير قابلة للتراجع بأمان.
- تعارض صريح بين عقدين معتمدين.

---

## [33. التقرير النهائي لأي مهمة]

يجب أن يوضح تقرير المنفذ:

1. ماذا فحص؟
2. ما مصدر الحقيقة؟
3. ماذا وجد؟
4. ما السبب الجذري إن كانت المهمة إصلاحًا؟
5. ماذا غيّر؟
6. ما الملفات أو الطبقات المتأثرة؟
7. ماذا لم يغيّر؟
8. ما الاختبارات التي شُغلت؟
9. النتائج وأكواد الخروج عندما تكون ذات صلة.
10. أي مخاطر متبقية.
11. أي توصية مهنية نافعة.
12. الحكم النهائي للمهمة.

لا تكفي عبارة "تم التنفيذ" دون دليل.

---

## [34. ديمومة السياسة]

هذه السياسة:

PERMANENT (دائمة)
MANDATORY (إلزامية)
PROJECT-WIDE (على مستوى المشروع كاملًا)

وتطبق على جميع التطويرات الحالية والمستقبلية في معمل ياسين.

لا يجوز لمنفذ لاحق تجاوزها بسبب عدم ذكرها داخل أمر مهمة فرعية.

أي أمر لاحق يُقرأ بوصفه خاضعًا لهذه السياسة تلقائيًا.

ولا يجوز تعديل السياسة أو تعطيل بند إلزامي منها دون قرار صريح من مالك المشروع.

---

## [35. إجراء التأسيس المطلوب الآن]

هذه مهمة تأسيس سياسة فقط.

المطلوب من المنفذ التقني:

1. قراءة هذه السياسة كاملة.
2. قراءة وثيقة المتطلبات المعتمدة لمعمل ياسين.
3. إنشاء ملف سياسة مركزي واحد داخل: D:\YASIN_WORKSHOP
4. اختيار اسم واضح مثل: YASIN_WORKSHOP_PERMANENT_DEVELOPMENT_POLICY.md
5. حفظ مضمون هذه السياسة كمرجع دائم للمشروع.
6. إنشاء مرجع واضح إليها في تعليمات التطوير الأساسية إذا احتاج المشروع ذلك.
7. عدم إنشاء ملفات سياسة متكررة تحمل البنود نفسها.
8. عدم كتابة أي ميزة أعمال في هذه المهمة.
9. عدم إنشاء قاعدة البيانات في هذه المهمة.
10. عدم البدء بشاشات العملاء أو الموظفين أو الموردين في هذه المهمة.

بعد ذلك يجب أن تصبح هذه السياسة مرجعًا إلزاميًا لكل مهمة لاحقة.

FINAL REQUIRED VERDICT:
A — YASIN WORKSHOP PERMANENT DEVELOPMENT POLICY ESTABLISHED

---

## الخلاصة النهائية

تُعد هذه السياسة المرجع الأعلى في مشروع معمل ياسين، وتطبق على جميع التطويرات والمهام اللاحقة، دون استثناء، ما لم يتم تعديلها بقرار صريح من المالك.

