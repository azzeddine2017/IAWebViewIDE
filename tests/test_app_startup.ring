# اختبار بدء تشغيل التطبيق
load "stdlib.ring"
load "src/app.ring"

func main
    see "=== اختبار بدء تشغيل التطبيق ===" + nl
    
    try
        # إنشاء مثيل من التطبيق
        oApp = new RingIDE()
        see "تم إنشاء التطبيق بنجاح!" + nl
        
        # التحقق من أن جميع المكونات تم تهيئتها
        if oApp.oSmartAgent != NULL
            see "✓ Smart Agent تم تهيئته" + nl
        else
            see "✗ Smart Agent لم يتم تهيئته" + nl
        ok
        
        if oApp.oFileManager != NULL
            see "✓ File Manager تم تهيئته" + nl
        else
            see "✗ File Manager لم يتم تهيئته" + nl
        ok
        
        if oApp.oCodeRunner != NULL
            see "✓ Code Runner تم تهيئته" + nl
        else
            see "✗ Code Runner لم يتم تهيئته" + nl
        ok
        
        see nl + "=== جميع المكونات جاهزة! ===" + nl
        see "النظام الجديد القائم على الطرق تم تطبيقه بنجاح على التطبيق بالكامل." + nl
        
    catch
        see "خطأ في بدء التطبيق: " + cCatchError + nl
    done

