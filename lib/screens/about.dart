import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 50.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  "درباره برنامه  ",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF393E46),
                        Color(0xFF00ADB5),
                      ],
                    ),
                  ),
                  // child: Center(
                  //   child: Icon(Icons.school, size: 60, color: Colors.white),
                  // ),
                ),
              ),
              backgroundColor: Color(0xFF393E46),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App description
                    _buildSectionTitle('معرفی برنامه'),
                    _buildSectionContent(
                        'برنامه kokocards یک ابزار برای سازماندهی و مدیریت کارت‌های آموزشی است. '
                            'با این برنامه می‌توانید به راحتی مطالب درسی، لغات زبان یا هر موضوع دیگری را به صورت فلش کارت ایجاد و مرور کنید به اشتراک بگذارید.'
                    ),
                    SizedBox(height: 20),

                    // Features
                    _buildSectionTitle('ویژگی‌های اصلی'),
                    _buildFeatureItem('ساخت پوشه‌های مختلف برای دسته‌بندی کارت‌ها'),
                    _buildFeatureItem('افزودن کارت با قابلیت ذخیره تلفظ، معنی و مثال'),
                    _buildFeatureItem('سیستم امتیازدهی به کارت‌ها برای پیگیری پیشرفت'),
                    _buildFeatureItem('قابلیت جستجو در میان تمام کارت‌ها'),
                    _buildFeatureItem('اشتراک‌گذاری کارت‌ها در قالب‌های مختلف (JSON, Excel, متن)'),
                    _buildFeatureItem('وارد کردن کارت‌ها از فایل‌های JSON و Excel'),
                    _buildFeatureItem('یادداشت‌گذاری برای هر پوشه'),
                    _buildFeatureItem('قابلیت اسکرول بین کارت های مورد نظر'),
                    SizedBox(height: 20),

                    // How to use
                    _buildSectionTitle('راهنمای استفاده'),
                    _buildSubSectionTitle('ایجاد پوشه جدید:'),
                    _buildSectionContent('از دکمه + در صفحه اصلی، گزینه ایجاد پوشه را انتخاب کنید. نام پوشه را وارد و رنگ مورد نظر را انتخاب نمایید.'),

                    _buildSubSectionTitle('افزودن کارت جدید:'),
                    _buildSectionContent('با ورود به هر پوشه، روی دکمه + کلیک کرده و اطلاعات کارت شامل عبارت، تلفظ، معنی و مثال را وارد نمایید.'),

                    _buildSubSectionTitle('فرمت‌های اشتراک‌گذاری:'),
                    _buildSectionContent('می‌توانید محتوای خود را در سه فرمت مختلف اشتراک‌گذاری کنید:'),
                    Padding(
                      padding: EdgeInsets.only(right: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _buildShareFeatureItem('اشتراک‌گذاری کل پوشه (همراه با کارت‌ها و یادداشت‌ها) در صفحه اصلی', Icons.folder),
                          _buildShareFeatureItem('اشتراک‌گذاری کارت‌های انتخاب شده داخل یک پوشه به صورت Json یا Excel یا متن', Icons.checklist),
                          _buildShareFeatureItem(' اشتراک‌گذاری یک کارت تنها از صفحه اسکرول به صورت متنی ', Icons.credit_card),


                        ],
                      ),
                    ),

                    // Import System

                    _buildSubSectionTitle('وارد کردن (import) فلش کارت از صفحه اصلی:'),
                    _buildSectionContent('در صفحه اصلی می‌توانید پوشه‌های ذخیره شده توسط برنامه (فایل‌های JSON) را به مجموعه پوشه‌های خود اضافه کنید.'),
                    _buildSectionContent('کارت‌هایی که خارج از پوشه هستند را می‌توانید در قالب JSON وارد کرده و در یک پوشه جدید با نام دلخواه ذخیره کنید.'),

                    _buildSubSectionTitle('وارد کردن فلش کارت در سطح پوشه:'),
                    _buildSectionContent('در داخل هر پوشه می‌توانید کارت‌های اشتراک‌گذاری شده را هم به صورت Excel و هم JSON اضافه کنید.'),

                    _buildSubSectionTitle('قالب‌های پشتیبانی شده:'),
                    _buildSectionContent('برنامه از دو قالب اصلی برای وارد کردن اطلاعات پشتیبانی می‌کند:'),

                    Padding(
                      padding: EdgeInsets.only(right: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildImportFormatFeatureItem('JSON (حاوی اطلاعات کامل پوشه یا فلش کارت ها خارج از پوشه )', Icons.code),
                          _buildImportFormatFeatureItem('Excel (تنها مناسب برای فلش کارت ها خارج از پوشه )', Icons.table_chart),
                        ],
                      ),
                    ),
                    _buildSubSectionTitle('افزودن یادداشت به پوشه:'),
                    _buildSectionContent('از منوی هر پوشه، گزینه یادداشت پوشه را انتخاب کرده و یادداشت‌های خود را وارد کنید.'),
                    SizedBox(height: 20),

                    // Navigation and Search System
                    _buildSectionTitle('سیستم پیمایش و جستجو'),
                    _buildSubSectionTitle('پیمایش بین کارت‌ها:'),
                    _buildSectionContent('با اسکرول عمودی می‌توانید بین کارت‌ها حرکت کنید. برای ورق زدن کارت (دیدن پشت کارت) از swipe افقی استفاده نمایید.'),

                    _buildSubSectionTitle('پیمایش بین کارت‌های انتخاب شده:'),
                    _buildSectionContent('با انتخاب کارت‌ها و کلیک روی دکمه Play، می‌توانید فقط بین کارت‌های انتخاب شده پیمایش کنید.'),
                    _buildSectionContent('با زدن گزینه ★ در پوشه ها میتوانید بر اساس تعداد ★ کارت ها را به صورت نزولی مرتب و پیمایش کنید .'),

                    _buildSubSectionTitle('جستجوی هوشمند:'),
                    _buildSectionContent('سیستم جستجو  نه تنها کارت‌های جستجو شده را پیدا می‌کند، بلکه آن‌ها را به صورت هوشمندانه‌ای مرتب می‌کند:'),

                    Padding(
                      padding: EdgeInsets.only(right: 16, top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSearchFeatureItem('کارت‌هایی که دقیقاً با عبارت جستجو شده مطابقت دارند در اولویت نمایش قرار می‌گیرند'),
                          _buildSearchFeatureItem('کارت‌هایی که عبارت جستجو شده در ابتدای آن‌ها قرار دارد اولویت بیشتری دارند'),
                          _buildSearchFeatureItem('کارت‌های کوتاه‌تر نسبت به کارت‌های طولانی‌تر اولویت دارند'),
                          _buildSearchFeatureItem('با اسکرول در نتایج جستجو، می‌توانید تفاوت‌های بین کلمات و عبارات مشابه را تشخیص دهید'),
                        ],
                      ),
                    ),

                    // _buildSubSectionTitle('نمایش تفاوت بین کلمات مشابه:'),
                    // _buildSectionContent('وقتی عبارتی را جستجو می‌کنید، برنامه به گونه‌ای نتایج را نمایش می‌دهد که به راحتی می‌توانید تفاوت‌های بین کلمات و ترکیبات مشابه را تشخیص دهید. این ویژگی برای یادگیری تفاوت‌های ظریف بین کلمات هم‌خانواده بسیار مفید است.'),
                     SizedBox(height: 20),

                    // Contact
                    _buildSectionTitle('ارتباط با ما'),
                    _buildSectionContent('برای دریافت پوشه‌ها و کارت‌های بیشتر، به کانال تلگرامی مراجعه کنید:'),
                    SizedBox(height: 10),

                    _buildContactItem(
                      'تلگرام:',
                      't.me/kokocardsapp',
                      Icons.send,
                    ),

                    _buildContactItem(
                      'گیت‌هاب:',
                      'github.com/Negar-Arian',
                      Icons.code,
                    ),

                    _buildContactItem(
                      'ایمیل:',
                      'ariannegar78@gmail.com',
                      Icons.email,
                    ),
                    SizedBox(height: 20),

                    // Version & Credits
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'نسخه 1.1.0',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'توسعه‌یافته توسط Negar  ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '© 2025 - تمام حقوق محفوظ است',
                            style: TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF00ADB5),
        ),
      ),
    );
  }

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 14,
          color: Colors.white,
          height: 1.5,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Color(0xFF00ADB5), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFeatureItem(String feature) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_left, color: Colors.white70, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF00ADB5), size: 22),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
Widget _buildShareFeatureItem(String feature, IconData icon) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF00ADB5), size: 20),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            feature,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Widget _buildImportFormatFeatureItem(String feature, IconData icon) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF00ADB5), size: 18),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            feature,
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}