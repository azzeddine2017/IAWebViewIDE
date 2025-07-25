# مثال تطبيقي - حاسبة بسيطة
# Created: 25/07/2025

load "stdlib.ring"

func main()
    see "=== حاسبة Ring البسيطة ===" + nl + nl
    
    # إدخال الأرقام
    see "أدخل الرقم الأول: "
    give nNum1
    nNum1 = number(nNum1)
    
    see "أدخل الرقم الثاني: "
    give nNum2  
    nNum2 = number(nNum2)
    
    # إدخال العملية
    see "اختر العملية (+, -, *, /): "
    give cOperation
    
    # تنفيذ العملية
    nResult = performOperation(nNum1, nNum2, cOperation)
    
    # عرض النتيجة
    if nResult != null
        see nl + "النتيجة: " + nNum1 + " " + cOperation + " " + nNum2 + " = " + nResult + nl
    ok

func performOperation(nNum1, nNum2, cOp)
    switch cOp
        on "+"
            return nNum1 + nNum2
        on "-"
            return nNum1 - nNum2
        on "*"
            return nNum1 * nNum2
        on "/"
            if nNum2 != 0
                return nNum1 / nNum2
            else
                see "خطأ: لا يمكن القسمة على صفر!" + nl
                return null
            ok
        other
            see "عملية غير صحيحة!" + nl
            return null
    off
