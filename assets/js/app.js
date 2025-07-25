// ===================================================================
// Ring IDE JavaScript Functions - AI Agent Powered
// ===================================================================

// Global variables
let currentFile = '';
let chatHistory = [];
let agentStatus = 'ready';

// ===================================================================
// Project Management Functions
// ===================================================================
function createProject() {
    const projectName = document.getElementById('projectName').value;
    if (projectName.trim()) {
        updateStatus('تم إنشاء المشروع: ' + projectName);
        updateFileList();
    }
}

function createNewFile() {
    const fileName = prompt('اسم الملف الجديد (مع الامتداد):');
    if (fileName) {
        window.createNewFile(fileName).then(result => {
            if (result) {
                updateFileList();
                updateStatus('تم إنشاء الملف: ' + fileName);
            }
        });
    }
}

// ===================================================================
// File Operations
// ===================================================================
function saveCurrentFile() {
    if (currentFile) {
        const code = editor.getValue();
        window.saveFile(currentFile, code).then(result => {
            if (result) {
                updateStatus('تم حفظ الملف: ' + currentFile);
            } else {
                updateStatus('خطأ في حفظ الملف');
            }
        });
    } else {
        const fileName = prompt('اسم الملف للحفظ:');
        if (fileName) {
            const code = editor.getValue();
            window.saveFile(fileName, code).then(result => {
                if (result) {
                    currentFile = fileName;
                    updateFileList();
                    updateStatus('تم حفظ الملف: ' + fileName);
                }
            });
        }
    }
}

function loadFile(fileName) {
    if (!fileName) {
        fileName = prompt('اسم الملف للفتح:');
    }
    if (fileName) {
        window.loadFile(fileName).then(content => {
            if (content) {
                editor.setValue(content);
                currentFile = fileName;
                updateStatus('تم فتح الملف: ' + fileName);
                highlightActiveFile(fileName);
            } else {
                updateStatus('خطأ في فتح الملف');
            }
        });
    }
}

// ===================================================================
// Code Operations
// ===================================================================
function runCode() {
    const code = editor.getValue();
    updateStatus('جاري تشغيل الكود بواسطة الوكيل الذكي...');

    // Use Smart Agent for code execution
    processAgentRequest('شغل هذا الكود: ' + code).then(result => {
        addChatMessage('ai', result);
        updateStatus('تم تشغيل الكود');
    });
}

function formatCode() {
    const code = editor.getValue();
    updateStatus('جاري تنسيق الكود...');

    // Use Smart Agent for code formatting
    processAgentRequest('نسق هذا الكود: ' + code).then(formattedResult => {
        // Try to extract formatted code from response
        if (formattedResult.includes('```')) {
            const codeMatch = formattedResult.match(/```[\s\S]*?\n([\s\S]*?)```/);
            if (codeMatch && codeMatch[1]) {
                editor.setValue(codeMatch[1].trim());
                updateStatus('تم تنسيق الكود');
                return;
            }
        }
        addChatMessage('ai', formattedResult);
        updateStatus('تم معالجة طلب التنسيق');
    });
}

function analyzeCode() {
    const code = editor.getValue();
    updateStatus('جاري تحليل الكود بواسطة الوكيل الذكي...');

    // Use Smart Agent for code analysis
    processAgentRequest('حلل هذا الكود واعطني تقريراً مفصلاً: ' + code).then(analysis => {
        addChatMessage('ai', analysis);
        updateStatus('تم تحليل الكود');
    });
}

// ===================================================================
// Smart Agent Functions
// ===================================================================
function processAgentRequest(message) {
    const currentCode = editor.getValue();
    updateStatus('معالجة الطلب بواسطة الوكيل الذكي...');

    return window.processRequest(message, currentCode).then(response => {
        updateStatus('تم معالجة الطلب بنجاح');
        return response;
    }).catch(error => {
        updateStatus('خطأ في معالجة الطلب');
        return 'عذراً، حدث خطأ في معالجة طلبك.';
    });
}

function getAgentStatus() {
    window.getAgentStatus().then(status => {
        console.log('Agent Status:', status);
        agentStatus = status;
    });
}

function setCurrentProject(projectName) {
    window.setCurrentProject(projectName).then(result => {
        updateStatus('تم تعيين المشروع: ' + projectName);
    });
}

function setCurrentFile(fileName) {
    currentFile = fileName;
    window.setCurrentFile(fileName).then(result => {
        updateStatus('تم تعيين الملف: ' + fileName);
    });
}

// ===================================================================
// Enhanced Chat Functions
// ===================================================================
function sendChatMessage() {
    const input = document.getElementById('chatInput');
    const message = input.value.trim();
    if (message) {
        addChatMessage('user', message);
        input.value = '';

        showChatLoading(true);

        // Use Smart Agent for processing
        processAgentRequest(message).then(response => {
            showChatLoading(false);
            addChatMessage('ai', response);
        });
    }
}

function handleChatKeyPress(event) {
    if (event.key === 'Enter') {
        sendChatMessage();
    }
}

function addChatMessage(sender, message) {
    const chatMessages = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message ' + sender;
    messageDiv.textContent = message;
    chatMessages.appendChild(messageDiv);
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function showChatLoading(show) {
    const loading = document.getElementById('chatLoading');
    loading.style.display = show ? 'block' : 'none';
}

// ===================================================================
// UI Helper Functions
// ===================================================================
function updateStatus(message) {
    document.getElementById('statusText').textContent = message;
}

function updateFileList() {
    window.getFileList().then(files => {
        const fileList = document.getElementById('fileList');
        fileList.innerHTML = '';
        
        if (files && files.length > 0) {
            files.forEach(file => {
                const fileDiv = document.createElement('div');
                fileDiv.className = 'file-item';
                fileDiv.textContent = file;
                fileDiv.onclick = () => loadFile(file);
                fileList.appendChild(fileDiv);
            });
        } else {
            fileList.innerHTML = '<div style="color: #7f8c8d; text-align: center; padding: 10px;">لا توجد ملفات</div>';
        }
    });
}

function highlightActiveFile(fileName) {
    const fileItems = document.querySelectorAll('.file-item');
    fileItems.forEach(item => {
        item.classList.remove('active');
        if (item.textContent === fileName) {
            item.classList.add('active');
        }
    });
}

// ===================================================================
// Agent Management Functions
// ===================================================================
function showAgentPanel() {
    const agentPanel = document.getElementById('agentPanel');
    if (agentPanel) {
        agentPanel.style.display = agentPanel.style.display === 'none' ? 'block' : 'none';
        if (agentPanel.style.display === 'block') {
            refreshAgentStatus();
        }
    }
}

function refreshAgentStatus() {
    getAgentStatus();
    const statusDiv = document.getElementById('agentStatusDisplay');
    if (statusDiv) {
        statusDiv.innerHTML = '<p>جاري تحديث حالة الوكيل...</p>';
        setTimeout(() => {
            statusDiv.innerHTML = `
                <h4>حالة الوكيل الذكي</h4>
                <p><strong>الحالة:</strong> ${agentStatus}</p>
                <p><strong>الملف الحالي:</strong> ${currentFile || 'غير محدد'}</p>
                <p><strong>عدد الرسائل:</strong> ${chatHistory.length}</p>
            `;
        }, 1000);
    }
}

function executeDirectCommand() {
    const commandInput = document.getElementById('directCommand');
    const command = commandInput.value.trim();

    if (command) {
        addChatMessage('user', 'أمر مباشر: ' + command);
        commandInput.value = '';

        showChatLoading(true);
        processAgentRequest(command).then(response => {
            showChatLoading(false);
            addChatMessage('ai', response);
        });
    }
}

function showToolsList() {
    processAgentRequest('اعرض لي قائمة الأدوات المتاحة').then(response => {
        addChatMessage('ai', response);
    });
}

// ===================================================================
// Keyboard Shortcuts
// ===================================================================
document.addEventListener('keydown', function(e) {
    if (e.ctrlKey && e.key === 'Enter') {
        sendChatMessage();
    }
    if (e.ctrlKey && e.key === 'r') {
        e.preventDefault();
        runCode();
    }
    if (e.key === 'F1') {
        e.preventDefault();
        showAgentPanel();
    }
});

// ===================================================================
// Initialize Application
// ===================================================================
document.addEventListener('DOMContentLoaded', function() {
    updateStatus('Ring Programming IDE - AI Agent جاهز للاستخدام');
    updateFileList();
    getAgentStatus();
});
