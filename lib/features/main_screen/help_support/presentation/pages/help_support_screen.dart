import 'package:flutter/material.dart';
import 'package:khadem/core/utils/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFFE6EFF9);

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'إزاي أستكمل بيانات حسابي؟',
      'answer':
          'افتح صفحة حسابك الشخصي، واضغط على تعديل البيانات لاستكمال أو تحديث بياناتك.',
    },
    {
      'question': 'إزاي أعدّل بياناتي الشخصية؟',
      'answer':
          'تقدر تعدّل بياناتك وصورتك الشخصية من صفحة الحساب، حسب البيانات المتاحة للتعديل.',
    },
    {
      'question': 'ليه حسابي لسه تحت المراجعة؟',
      'answer':
          'بعض الحسابات تحتاج إلى مراجعة مسؤول الكنيسة قبل تفعيل جميع المميزات. لو استمرت المشكلة، تواصل مع مسؤول الكنيسة.',
    },
    {
      'question': 'اتاحية المرنم والخادم؟؟',
      'answer':
          'تقدر تعلن انك متاح في يوم معين وتقدر تستقبل في دعوة عن طريق. زرار تحديد الموجود تحت تقويم النتيجة',
    },
    {
      'question': 'أعمل إيه لو مش عارف أسجّل الدخول؟',
      'answer':
          'تأكد من صحة البريد الإلكتروني وكلمة المرور، ومن اتصالك بالإنترنت، ثم حاول مرة أخرى.',
    },
    {
      'question': 'إزاي أتابع الاجتماعات والأنشطة؟',
      'answer':
          'افتح قسم الأجندة داخل التطبيق لمتابعة المواعيد والأنشطة المتاحة لك.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: const Text('المساعدة والدعم'),
        centerTitle: true,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSectionTitle('عن تطبيق خِدمتي'),
          const SizedBox(height: 10),
          _buildAboutCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('الأسئلة الشائعة'),
          const SizedBox(height: 10),
          _buildFaqCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('عن المطوّر'),
          const SizedBox(height: 10),
          _buildDeveloperCard(),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'خِدمتي — لأن التنظيم الأفضل بيساعدنا نخدم بصورة أفضل ❤️',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.volunteer_activism_rounded,
              color: primaryBlue,
              size: 32,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إزاي نقدر نساعدك؟',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'هنا هتلاقي معلومات تساعدك تستخدم خِدمتي بسهولة.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: primaryBlue,
      ),
    );
  }

  Widget _buildAboutCard() {
    return _card(
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.church_rounded, color: primaryBlue, size: 27),
              SizedBox(width: 10),
              Text(
                'خِدمتي',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'خِدمتي تطبيق هدفه تسهيل تنظيم الخدمة الكنسية، '
            'مساعدة مسؤلين الاجتماعات للوصول للمرنمين والخدام وفرق التسبيح والدراما لاجتماعتهم'
            '.\n\n'
            ' ولو انت خادم ( مرنم - واعظ - فريق تسبيح أو دراما - تقدر تقدم خدمة) التطبيق بيساعدك تنظم خدمتك وتنظم تحركاتك في مواعيد الاجنده وتعلن اتاحيتك في وقت معين '
            'وتتابع كل الاجتماعات والأنشطة الخاصة بيهم من خلال التطبيق.\n\n'
            'بنسعى إن التكنولوجيا تساعدنا ننظّم خدمتنا بشكل أفضل، '
            'وتوفّر وقت ومجهود علشان يكون تركيزنا الأكبر على الخدمة نفسها.',
            style: TextStyle(fontSize: 14, height: 1.8, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: ExpansionPanelList.radio(
        elevation: 0,
        expandedHeaderPadding: EdgeInsets.zero,
        materialGapSize: 0,
        children: _faqs.map((faq) {
          return ExpansionPanelRadio(
            value: faq['question']!,
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    faq['question']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
            body: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  faq['answer']!,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.7,
                    color: AppColors.blueLightColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeveloperCard() {
    return _card(
      child: const Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundImage: const AssetImage('assets/images/ProfilePic.png'),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Giovanni Arwen',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 5),
                Text(
                  'Flutter Developer & App Creator',
                  style: TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'بهدف إن التكنولوجيا تساعدنا ننظّم الخدمة ونخلي تجربتنا أسهل.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: child,
    );
  }
}
