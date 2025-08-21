
    // Quill 모듈 등록
    Quill.register('modules/resize', window.QuillResizeImage);
    const rawTableUI = window.QuillTableUI || window.quillTableUI;
    if (rawTableUI) {
        const mod = rawTableUI.default || rawTableUI;
        Quill.register({ 'modules/tableUI': mod }, true);
    }

    document.addEventListener('DOMContentLoaded', () => {
        const titleInput = document.getElementById('titleInput');
        const editorDiv = document.getElementById('editor');
        const submitBtn = document.getElementById('submitBtn');

        // Draft 불러오기
        titleInput.value = localStorage.getItem('draftTitle') || '';
        const quill = new Quill('#editor', {
            theme: 'snow',
            modules: {
                toolbar: [
                    [{ header: [1, 2, 3, false] }],
                    ['bold', 'italic', 'underline', 'strike'],
                    [{ color: [] }, { background: [] }],
                    [{ align: [] }],
                    ['link', 'image', 'table'],
                    ['clean'], ['code']
                ],
                handlers: {
                    // 기본 'image' 핸들러를 커스터마이징
                    image: imageHandler
                },
                resize: {}, table: true, tableUI: true
            }
        });
        quill.root.innerHTML = localStorage.getItem('draftContent') || '';

        // 이미지 삽입 버튼 눌렀을 때 실행될 함수
        function imageHandler() {
            const input = document.createElement('input');
            input.setAttribute('type', 'file');
            input.setAttribute('accept', 'image/*');
            input.click();
            input.onchange = async () => {
                const file = input.files[0];
                if (!file) return;
                // 파일을 base64로 읽어서 Flutter 쪽으로 전송
                const reader = new FileReader();
                reader.onload = () => {
                    const base64 = reader.result.split(',')[1];
                    // Flutter WebView 또는 postMessage
                    if (window.flutter_inappwebview) {
                        window.flutter_inappwebview
                            .callHandler('uploadImage', base64, file.name)
                            .then((url) => insertToEditor(url));
                    } else {
                        window.parent.postMessage(
                            { type: 'uploadImage', payload: { base64, name: file.name } },
                            '*'
                        );
                    }
                };
                reader.readAsDataURL(file);
            };
        }

        // 업로드가 완료된 후 에디터에 삽입
        function insertToEditor(url) {
            const range = quill.getSelection(true);
            quill.insertEmbed(range.index, 'image', url);
            quill.setSelection(range.index + 1);
        }

        // 입력 상태에 따라 버튼 활성화/비활성화
        function updateUI() {
            const t = titleInput.value.trim();
            const c = quill.getText().trim();
            submitBtn.disabled = !(t && c);
        }

        // 제목•본문 변동 시 Draft 저장 & Flutter에 실시간 전송
        function trackChange() {
            // ① Draft 저장
            localStorage.setItem('draftTitle', titleInput.value);
            localStorage.setItem('draftContent', quill.root.innerHTML);

            // ② Flutter/WebView에 전송
            const payload = {
                title: titleInput.value,
                content: quill.root.innerHTML
            };
            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onTextChange', payload);
            } else {
                window.parent.postMessage({ type: 'onTextChange', payload }, '*');
            }
        }

        // 이벤트 바인딩
        titleInput.addEventListener('input', () => {
            updateUI();
            trackChange();
        });
        quill.on('text-change', () => {
            updateUI();
            trackChange();
        });

        // 작성하기 클릭 시 onSubmit 호출 & Draft 지우기
        submitBtn.addEventListener('click', () => {
            const payload = {
                title: titleInput.value.trim(),
                content: quill.root.innerHTML
            };
            localStorage.removeItem('draftTitle');
            localStorage.removeItem('draftContent');

            if (window.flutter_inappwebview) {
                window.flutter_inappwebview.callHandler('onSubmit', payload);
            } else {
                window.parent.postMessage({ type: 'onSubmit', payload }, '*');
            }
        });

        // 초기 UI 업데이트
        updateUI();
        // 디버깅용
        window.myQuill = quill;
    });