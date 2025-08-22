// Ring Programming IDE - JavaScript Functions
// Modern and Clean Implementation

// Global variables
let editor;
let currentFile = 'main.ring';
let chatCollapsed = false;

// Initialize CodeMirror Editor
function initializeEditor() {
    editor = CodeMirror.fromTextArea(document.getElementById('codeEditor'), {
        theme: 'material-darker',
        lineNumbers: true,
        mode: 'javascript', // Using JavaScript mode for Ring syntax highlighting
        autoCloseBrackets: true,
        matchBrackets: true,
        styleActiveLine: true,
        indentUnit: 4,
        tabSize: 4,
        lineWrapping: true,
        extraKeys: {
            "Ctrl-Space": "autocomplete",
            "Ctrl-S": function(cm) { saveFile(); },
            "Ctrl-O": function(cm) { openFile(); },
            "Ctrl-N": function(cm) { newFile(); },
            "F5": function(cm) { runCode(); },
            "Ctrl-F": "findPersistent",
            "Ctrl-H": "replace"
        }
    });

    // Update status bar on cursor activity
    editor.on('cursorActivity', function() {
        const cursor = editor.getCursor();
        updateStatusBar(`السطر: ${cursor.line + 1} | العمود: ${cursor.ch + 1} | Ring v1.19`);
    });

    // Auto-save indication
    editor.on('change', function() {
        updateStatus('تم تعديل الملف');
    });
}

// File Management Functions
async function createNewFile() {
    console.log('createNewFile function called');
    const fileName = document.getElementById('fileName').value.trim();
    if (!fileName) {
        updateStatus('يرجى إدخال اسم الملف');
        return;
    }

    try {
        updateStatus('جاري إنشاء الملف...');
        showLoading(true);

        // Send parameters in the correct format for Ring
        const params = [fileName];
        console.log('Calling Ring function with params:', params);

        // Check if Ring function exists
        if (typeof window.createNewFile === 'function') {
            console.log('Ring function createNewFile found');
            const result = await window.createNewFile(JSON.stringify(params));
            console.log('Create file result:', result);
            console.log('Result type:', typeof result);

            // تحسين معالجة الاستجابة
            let parsedResult = result;
            if (typeof result === 'string') {
                try {
                    parsedResult = JSON.parse(result);
                } catch (e) {
                    console.log('Result is not JSON, treating as plain response');
                }
            }

            if (parsedResult && (parsedResult.success === true || parsedResult.success === "true")) {
                updateStatus('✅ تم إنشاء الملف: ' + fileName);
                document.getElementById('fileName').value = '';

                // Add to file list UI directly instead of calling updateFileList
                addFileToList(fileName, true);
                console.log('File created successfully');

                // إضافة رسالة في الشات
                addMessage('system', 'نجح العمل:', 'تم إنشاء الملف ' + fileName + ' بنجاح');

            } else if (parsedResult && parsedResult.error) {
                updateStatus('❌ خطأ في إنشاء الملف: ' + parsedResult.error);
                console.error('Ring error:', parsedResult.error);
                addMessage('system', 'خطأ:', parsedResult.error);
            } else {
                updateStatus('⚠️ استجابة غير متوقعة من الخادم');
                console.error('Unexpected result:', parsedResult);
                addMessage('system', 'تحذير:', 'استجابة غير متوقعة: ' + JSON.stringify(parsedResult));
            }
        } else {
            console.error('Ring function createNewFile not found');
            console.log('Available window functions:', Object.keys(window).filter(key => typeof window[key] === 'function'));
            updateStatus('❌ خطأ: وظيفة إنشاء الملف غير متوفرة');
            addMessage('system', 'خطأ:', 'وظيفة إنشاء الملف غير متوفرة في النظام');
            return;
        }

    } catch (error) {
        console.error('Error creating file:', error);
        updateStatus('❌ فشل في إنشاء الملف: ' + error.message);
        addMessage('system', 'خطأ:', 'فشل في إنشاء الملف: ' + error.message);
    } finally {
        showLoading(false);
    }
}

// Connection Test Function
async function testConnection() {
    console.log('=== Testing Ring Connection ===');

    // Show test results panel
    const testResults = document.getElementById('testResults');
    const connectionStatus = document.getElementById('connectionStatus');

    testResults.style.display = 'block';
    connectionStatus.innerHTML = '🔄 جاري اختبار الربط مع Ring Backend...<br><br>';

    const functions = [
        'createNewFile',
        'runCode',
        'sendAIRequest',
        'getFileList',
        'saveFile',
        'loadFile',
        'chatWithAI'
    ];

    let results = '<h4>📋 فحص الوظائف المتاحة:</h4>';
    let workingCount = 0;

    // Check function availability
    functions.forEach(func => {
        const available = typeof window[func] === 'function';
        if (available) workingCount++;
        results += `<div style="margin: 5px 0;">${available ? '✅' : '❌'} ${func}</div>`;
    });

    connectionStatus.innerHTML = results + '<br>';

    // Test actual function calls
    results += '<br><h4>🧪 اختبار الوظائف:</h4>';

    try {
        // Test createNewFile
        if (typeof window.createNewFile === 'function') {
            results += '<div style="margin: 5px 0;">🔄 اختبار إنشاء ملف...</div>';
            connectionStatus.innerHTML = results;

            const createResult = await window.createNewFile(JSON.stringify(['test_connection.ring']));
            results += `<div style="margin: 5px 0;">✅ إنشاء الملف: ${JSON.stringify(createResult)}</div>`;
        }

        // Test runCode
        if (typeof window.runCode === 'function') {
            results += '<div style="margin: 5px 0;">🔄 اختبار تشغيل الكود...</div>';
            connectionStatus.innerHTML = results;

            const runResult = await window.runCode(JSON.stringify(['see "مرحباً من Ring!" + nl']));
            results += `<div style="margin: 5px 0;">✅ تشغيل الكود: ${JSON.stringify(runResult)}</div>`;
        }

        // Test sendAIRequest
        if (typeof window.sendAIRequest === 'function') {
            results += '<div style="margin: 5px 0;">🔄 اختبار الشات الذكي...</div>';
            connectionStatus.innerHTML = results;

            const aiResult = await window.sendAIRequest(JSON.stringify(['مرحباً', '']));
            results += `<div style="margin: 5px 0;">✅ الشات الذكي: ${JSON.stringify(aiResult)}</div>`;
        }

        results += '<br><h4>📊 النتيجة النهائية:</h4>';
        if (workingCount === functions.length) {
            results += '<div style="color: #4CAF50; font-weight: bold;">🎉 جميع الوظائف تعمل بشكل مثالي!</div>';
            results += '<div>✅ الواجهة مربوطة بالكامل مع Ring Backend</div>';
        } else if (workingCount > 0) {
            results += `<div style="color: #FF9800; font-weight: bold;">⚠️ ${workingCount}/${functions.length} وظائف تعمل</div>`;
            results += '<div>🔧 بعض الوظائف تحتاج إصلاح</div>';
        } else {
            results += '<div style="color: #F44336; font-weight: bold;">❌ لا توجد وظائف تعمل</div>';
            results += '<div>🚨 الواجهة غير مربوطة مع Ring Backend</div>';
        }

    } catch (error) {
        results += `<div style="color: #F44336;">❌ خطأ في الاختبار: ${error.message}</div>`;
    }

    connectionStatus.innerHTML = results;
    updateStatus('تم إنجاز اختبار الربط');
}

async function openFile() {
    try {
        updateStatus('جاري فتح الملف...');
        showLoading(true);
        
        const result = await window.openFile(JSON.stringify([]));
        console.log('Open file result:', result);
        
        if (result && result.content) {
            editor.setValue(result.content);
            currentFile = result.fileName || 'untitled.ring';
            updateStatus('تم فتح الملف: ' + currentFile);
        }
        
    } catch (error) {
        console.error('Error opening file:', error);
        updateStatus('فشل في فتح الملف');
    } finally {
        showLoading(false);
    }
}

async function saveFile() {
    try {
        updateStatus('جاري حفظ الملف...');
        showLoading(true);
        
        const content = editor.getValue();
        const params = [currentFile, content];
        const result = await window.saveFile(JSON.stringify(params));
        console.log('Save file result:', result);
        
        updateStatus('تم حفظ الملف: ' + currentFile);
        
    } catch (error) {
        console.error('Error saving file:', error);
        updateStatus('فشل في حفظ الملف');
    } finally {
        showLoading(false);
    }
}

async function deleteFile() {
    if (!confirm('هل أنت متأكد من حذف الملف؟')) {
        return;
    }

    try {
        updateStatus('جاري حذف الملف...');
        showLoading(true);
        
        const params = [currentFile];
        const result = await window.deleteFile(JSON.stringify(params));
        console.log('Delete file result:', result);
        
        updateStatus('تم حذف الملف: ' + currentFile);
        editor.setValue('');
        currentFile = 'untitled.ring';
        
    } catch (error) {
        console.error('Error deleting file:', error);
        updateStatus('فشل في حذف الملف');
    } finally {
        showLoading(false);
    }
}

// Project Management Functions
async function createProject() {
    const projectName = document.getElementById('projectName').value.trim();
    if (!projectName) {
        updateStatus('يرجى إدخال اسم المشروع');
        return;
    }

    try {
        updateStatus('جاري إنشاء المشروع...');
        showLoading(true);
        
        const params = [projectName];
        console.log('Calling createProject with params:', params);

        if (typeof window.createProject === 'function') {
            const result = await window.createProject(JSON.stringify(params));
            console.log('Create project result:', result);

            if (result && result.success) {
                updateStatus('✓ تم إنشاء المشروع: ' + projectName);
                document.getElementById('projectName').value = '';
                console.log('Project created successfully:', result);
            } else if (result && result.error) {
                updateStatus('✗ خطأ: ' + result.error);
                console.error('Project creation error:', result.error);
            } else {
                updateStatus('✗ استجابة غير متوقعة من الخادم');
                console.error('Unexpected result:', result);
            }
        } else {
            updateStatus('✗ دالة إنشاء المشروع غير متاحة');
            console.error('createProject function not found');
        }
        
    } catch (error) {
        console.error('Error creating project:', error);
        updateStatus('فشل في إنشاء المشروع');
    } finally {
        showLoading(false);
    }
}

async function openProject() {
    try {
        updateStatus('جاري البحث عن المشاريع...');
        showLoading(true);

        console.log('Calling openProject...');

        if (typeof window.openProject === 'function') {
            const result = await window.openProject(JSON.stringify([]));
            console.log('Open project result:', result);

            if (result && result.success) {
                if (result.projects && result.projects.length > 0) {
                    updateStatus('✓ تم العثور على ' + result.projects.length + ' مشروع: ' + result.projects.join(', '));
                    console.log('Available projects:', result.projects);
                } else {
                    updateStatus('✓ ' + result.message);
                }
            } else if (result && result.error) {
                updateStatus('✗ خطأ: ' + result.error);
                console.error('Open project error:', result.error);
            } else {
                updateStatus('✗ استجابة غير متوقعة من الخادم');
                console.error('Unexpected result:', result);
            }
        } else {
            updateStatus('✗ دالة فتح المشروع غير متاحة');
            console.error('openProject function not found');
        }

    } catch (error) {
        console.error('Error opening project:', error);
        updateStatus('✗ فشل في فتح المشروع: ' + error.message);
    } finally {
        showLoading(false);
    }
}

async function saveProject() {
    try {
        updateStatus('جاري حفظ المشروع...');
        showLoading(true);

        console.log('Calling saveProject...');

        if (typeof window.saveProject === 'function') {
            const result = await window.saveProject(JSON.stringify([]));
            console.log('Save project result:', result);

            if (result && result.success) {
                updateStatus('✓ ' + result.message);
                console.log('Project saved successfully');
            } else if (result && result.error) {
                updateStatus('✗ خطأ: ' + result.error);
                console.error('Save project error:', result.error);
            } else {
                updateStatus('✗ استجابة غير متوقعة من الخادم');
                console.error('Unexpected result:', result);
            }
        } else {
            updateStatus('✗ دالة حفظ المشروع غير متاحة');
            console.error('saveProject function not found');
        }

    } catch (error) {
        console.error('Error saving project:', error);
        updateStatus('✗ فشل في حفظ المشروع: ' + error.message);
    } finally {
        showLoading(false);
    }
}

// Code Execution Functions
async function runCode() {
    try {
        updateStatus('جاري تشغيل الكود...');
        showLoading(true);

        const code = editor.getValue();
        console.log('Running code:', code.substring(0, 100) + '...');

        if (typeof window.runCode === 'function') {
            const params = [code];
            console.log('Sending code parameters:', params);
            const result = await window.runCode(JSON.stringify(params));
            console.log('Run code result:', result);
            console.log('Result type:', typeof result);

            // تحسين معالجة الاستجابة
            let parsedResult = result;
            if (typeof result === 'string') {
                try {
                    parsedResult = JSON.parse(result);
                } catch (e) {
                    console.log('Result is not JSON, treating as plain response');
                }
            }

            if (parsedResult && (parsedResult.success === true || parsedResult.output)) {
                updateStatus('✅ تم تشغيل الكود بنجاح');
                const output = parsedResult.output || 'تم تشغيل الكود بنجاح';
                addMessage('system', '🎯 نتيجة التشغيل:', output);
            } else if (parsedResult && parsedResult.error) {
                updateStatus('❌ خطأ في تشغيل الكود: ' + parsedResult.error);
                addMessage('system', '❌ خطأ في التشغيل:', parsedResult.error);
            } else {
                updateStatus('⚠️ تم تشغيل الكود - استجابة غير متوقعة');
                addMessage('system', '⚠️ تم التشغيل', 'تم تشغيل الكود لكن الاستجابة غير واضحة: ' + JSON.stringify(parsedResult));
            }
        } else {
            console.error('Ring function runCode not found');
            updateStatus('❌ خطأ: وظيفة تشغيل الكود غير متوفرة');
            addMessage('system', '❌ خطأ', 'وظيفة تشغيل الكود غير متوفرة في النظام');
        }

    } catch (error) {
        console.error('Error running code:', error);
        updateStatus('❌ خطأ في تشغيل الكود');
        addMessage('system', '❌ خطأ في التشغيل:', error.message || 'خطأ غير معروف');
    } finally {
        showLoading(false);
    }
}

async function debugCode() {
    try {
        updateStatus('جاري تصحيح الأخطاء...');
        showLoading(true);
        
        const code = editor.getValue();
        const params = [code];
        const result = await window.debugCode(JSON.stringify(params));
        console.log('Debug code result:', result);
        
        updateStatus('تم تصحيح الأخطاء');
        
    } catch (error) {
        console.error('Error debugging code:', error);
        updateStatus('فشل في تصحيح الأخطاء');
    } finally {
        showLoading(false);
    }
}

async function formatCode() {
    try {
        updateStatus('جاري تنسيق الكود...');
        showLoading(true);
        
        const code = editor.getValue();
        const params = [code];
        const result = await window.formatCode(JSON.stringify(params));
        console.log('Format code result:', result);
        
        if (result && result.formattedCode) {
            editor.setValue(result.formattedCode);
            updateStatus('تم تنسيق الكود');
        }
        
    } catch (error) {
        console.error('Error formatting code:', error);
        updateStatus('فشل في تنسيق الكود');
    } finally {
        showLoading(false);
    }
}

// AI Chat Functions
async function sendMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();

    if (!message) return;

    // Add user message to chat
    addMessage('user', '👤 أنت:', message);
    input.value = '';

    try {
        updateStatus('جاري إرسال الرسالة للذكاء الاصطناعي...');
        showLoading(true);

        // Check if AI function exists
        if (typeof window.sendAIRequest === 'function') {
            const params = [message, editor.getValue()];
            console.log('Sending AI request with params:', params);
            const result = await window.sendAIRequest(JSON.stringify(params));
            console.log('AI request result:', result);
            console.log('Result type:', typeof result);

            // تحسين معالجة الاستجابة
            let parsedResult = result;
            if (typeof result === 'string') {
                try {
                    parsedResult = JSON.parse(result);
                } catch (e) {
                    console.log('AI result is not JSON, treating as plain response');
                }
            }

            if (parsedResult && parsedResult.response) {
                const aiIcon = parsedResult.demo_mode ? '🤖 (وضع تجريبي)' : '🤖 المساعد الذكي:';
                addMessage('ai', aiIcon, parsedResult.response);
                updateStatus('✅ تم استلام رد الذكاء الاصطناعي');
            } else if (parsedResult && parsedResult.error) {
                addMessage('ai', '❌ خطأ:', parsedResult.error);
                updateStatus('❌ خطأ في الذكاء الاصطناعي: ' + parsedResult.error);
            } else {
                addMessage('ai', '⚠️ استجابة غير متوقعة:', JSON.stringify(parsedResult));
                updateStatus('⚠️ استجابة غير متوقعة من الذكاء الاصطناعي');
            }
        } else {
            console.error('AI function sendAIRequest not found');
            addMessage('ai', '❌ خطأ:', 'وظيفة الذكاء الاصطناعي غير متوفرة في النظام');
            updateStatus('❌ وظيفة الذكاء الاصطناعي غير متوفرة');
        }

    } catch (error) {
        console.error('Error sending message:', error);
        addMessage('ai', '❌ خطأ:', 'عذراً، حدث خطأ في الاتصال بالذكاء الاصطناعي: ' + error.message);
        updateStatus('❌ فشل في إرسال الرسالة');
    } finally {
        showLoading(false);
    }
}

function addMessage(type, sender, content) {
    const messagesContainer = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}`;
    
    const avatarIcon = type === 'user' ? 'fa-user' : 
                      type === 'ai' ? 'fa-robot' : 'fa-info-circle';
    
    const currentTime = new Date().toLocaleTimeString('ar-SA', {
        hour: '2-digit',
        minute: '2-digit'
    });
    
    messageDiv.innerHTML = `
        <div class="message-avatar">
            <i class="fas ${avatarIcon}"></i>
        </div>
        <div class="message-content">
            <div class="message-text">${content}</div>
            <div class="message-time">${currentTime}</div>
        </div>
    `;
    
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// UI Functions
function toggleChat() {
    const chatPanel = document.getElementById('chatPanel');
    const toggleBtn = document.querySelector('.chat-toggle i');

    chatCollapsed = !chatCollapsed;

    if (chatCollapsed) {
        chatPanel.classList.add('collapsed');
        toggleBtn.className = 'fas fa-chevron-left';
    } else {
        chatPanel.classList.remove('collapsed');
        toggleBtn.className = 'fas fa-chevron-right';
    }
}

function toggleTheme() {
    // Theme toggle functionality
    const currentTheme = editor.getOption('theme');
    const newTheme = currentTheme === 'material-darker' ? 'default' : 'material-darker';
    editor.setOption('theme', newTheme);
    updateStatus('تم تغيير المظهر');
}

function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
        updateStatus('تم تفعيل وضع ملء الشاشة');
    } else {
        document.exitFullscreen();
        updateStatus('تم إلغاء وضع ملء الشاشة');
    }
}

function showSettings() {
    addMessage('system', 'الإعدادات:', 'سيتم إضافة نافذة الإعدادات قريباً');
}

function newFile() {
    if (confirm('هل تريد إنشاء ملف جديد؟ سيتم فقدان التغييرات غير المحفوظة.')) {
        editor.setValue('# ملف Ring جديد\n\nload "stdlib.ring"\n\nfunc main\n    see "مرحباً بالعالم!" + nl\n');
        currentFile = 'untitled.ring';
        updateStatus('تم إنشاء ملف جديد');
    }
}

function undoAction() {
    editor.undo();
    updateStatus('تم التراجع');
}

function redoAction() {
    editor.redo();
    updateStatus('تم الإعادة');
}

function findReplace() {
    editor.execCommand('findPersistent');
}

// Utility Functions
function updateStatus(message) {
    document.getElementById('statusText').textContent = message;
    setTimeout(() => {
        const cursor = editor.getCursor();
        document.getElementById('statusText').textContent =
            `السطر: ${cursor.line + 1} | العمود: ${cursor.ch + 1} | Ring v1.19`;
    }, 3000);
}

function updateStatusBar(message) {
    const statusInfo = document.querySelector('.status-info span');
    if (statusInfo) {
        statusInfo.textContent = message;
    }
}

function showLoading(show) {
    const loadingOverlay = document.getElementById('loadingOverlay');
    if (show) {
        loadingOverlay.classList.add('show');
    } else {
        loadingOverlay.classList.remove('show');
    }
}

let isUpdatingFileList = false;

async function updateFileList() {
    // Prevent multiple simultaneous calls
    if (isUpdatingFileList) {
        console.log('File list update already in progress, skipping...');
        return;
    }

    isUpdatingFileList = true;

    try {
        console.log('Updating file list...');

        // Check if Ring function exists
        if (typeof window.getFileList !== 'function') {
            console.error('Ring function getFileList not found');
            return;
        }

        const result = await window.getFileList(JSON.stringify([]));
        console.log('File list result:', result);

        if (result && result.files) {
            const fileListContainer = document.getElementById('fileList');
            if (fileListContainer) {
                fileListContainer.innerHTML = '';

                result.files.forEach(file => {
                    addFileToList(file.name, file.active);
                });

                console.log('File list updated successfully');
            }
        }
    } catch (error) {
        console.error('Error updating file list:', error);
    } finally {
        isUpdatingFileList = false;
    }
}

function addFileToList(fileName, isActive = false) {
    const fileListContainer = document.getElementById('fileList');
    const fileItem = document.createElement('div');
    fileItem.className = `file-item ${isActive ? 'active' : ''}`;
    fileItem.onclick = () => selectFile(fileName);

    const extension = fileName.split('.').pop().toLowerCase();
    const iconClass = extension === 'ring' ? 'fa-file-code' :
                     extension === 'md' ? 'fa-file-alt' : 'fa-file';

    fileItem.innerHTML = `
        <i class="fas ${iconClass}"></i>
        <span>${fileName}</span>
    `;

    fileListContainer.appendChild(fileItem);
}

async function selectFile(fileName) {
    try {
        updateStatus('جاري تحميل الملف...');
        showLoading(true);

        const params = [fileName];
        const result = await window.loadFile(JSON.stringify(params));

        if (result && result.content !== undefined) {
            editor.setValue(result.content);
            currentFile = fileName;
            updateStatus('تم تحميل الملف: ' + fileName);

            // Update active file in UI
            document.querySelectorAll('.file-item').forEach(item => {
                item.classList.remove('active');
                if (item.textContent.includes(fileName)) {
                    item.classList.add('active');
                }
            });
        }

    } catch (error) {
        console.error('Error loading file:', error);
        updateStatus('فشل في تحميل الملف');
    } finally {
        showLoading(false);
    }
}

// Event Listeners
document.addEventListener('DOMContentLoaded', function() {
    console.log('DOM Content Loaded - Initializing IDE...');
    initializeEditor();
    updateStatus('مرحباً بك في Ring Programming IDE');

    // Auto-test Ring connection after 2 seconds
    setTimeout(() => {
        console.log('Auto-testing Ring connection...');
        const functions = ['createNewFile', 'runCode', 'sendAIRequest', 'getFileList'];
        let available = 0;
        functions.forEach(func => {
            if (typeof window[func] === 'function') available++;
        });
        console.log(`Ring functions available: ${available}/${functions.length}`);
        if (available > 0) {
            updateStatus(`✅ Ring Backend متصل - ${available}/${functions.length} وظائف متاحة`);
        } else {
            updateStatus('❌ Ring Backend غير متصل - استخدم زر "اختبار الربط"');
        }
    }, 2000);

    // Add enter key listener for chat input
    const chatInput = document.getElementById('chatInput');
    if (chatInput) {
        chatInput.addEventListener('keypress', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });

        // Add auto-resize for chat input
        chatInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 120) + 'px';
        });
    }

    // Test button functionality
    console.log('Testing button functions availability:');
    console.log('createNewFile:', typeof window.createNewFile);
    console.log('runCode:', typeof window.runCode);
    console.log('sendMessage:', typeof window.sendMessage);

    // Add sample Ring code to editor
    if (editor) {
        editor.setValue(`# مرحباً بك في Ring Programming IDE
# هذا مثال بسيط لبرنامج Ring

load "stdlib.ring"

func main
    see "مرحباً بالعالم من Ring!" + nl
    see "Ring Programming Language" + nl

    # مثال على الحلقات
    for i = 1 to 5
        see "العدد: " + i + nl
    next

    # مثال على القوائم
    aNumbers = [1, 2, 3, 4, 5]
    see "القائمة: " + list2str(aNumbers) + nl


`);
    }
});

// Make functions globally available for onclick handlers
window.createNewFile = createNewFile;
window.openFile = openFile;
window.saveFile = saveFile;
window.deleteFile = deleteFile;
window.createProject = createProject;
window.openProject = openProject;
window.saveProject = saveProject;
window.runCode = runCode;
window.debugCode = debugCode;
window.formatCode = formatCode;
window.sendMessage = sendMessage;
window.toggleChat = toggleChat;
window.toggleTheme = toggleTheme;
window.toggleFullscreen = toggleFullscreen;
window.showSettings = showSettings;
window.newFile = newFile;
window.undoAction = undoAction;
window.redoAction = redoAction;
window.findReplace = findReplace;
window.testConnection = testConnection;
