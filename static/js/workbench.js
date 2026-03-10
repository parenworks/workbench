function setupFlashDismiss() {
    var flash = document.querySelector('.flash-message');
    __PS_MV_REG = [];
    return flash ? setTimeout(function () {
        flash.style.opacity = '0';
        __PS_MV_REG = [];
        return setTimeout(function () {
            return flash.style.display = 'none';
        }, 300);
    }, 5000) : null;
};function confirmAction(message) {
    return window.confirm(message);
};function setupAutofocus() {
    var input = document.querySelector('form .form-input, form .form-textarea');
    return input ? input.focus() : null;
};function setupSearch() {
    var searchInput = document.querySelector('.search-input');
    if (searchInput) {
        return searchInput.addEventListener('input', function (e) {
            var query = e.target.value.toLowerCase();
            var rows = document.querySelectorAll('table tbody tr');
            return rows.forEach(function (row) {
                var text = row.textContent.toLowerCase();
                return row.style.display = text.includes(query) ? '' : 'none';
            });
        });
    };
};function setupShortcuts() {
    return document.addEventListener('keydown', function (e) {
        if (e.altKey && !e.ctrlKey) {
            if (e.key == 'd') {
                e.preventDefault();
                return window.location = '/';
            } else if (e.key == 'c') {
                e.preventDefault();
                return window.location = '/clients';
            } else if (e.key == 'p') {
                e.preventDefault();
                return window.location = '/projects';
            } else if (e.key == 't') {
                e.preventDefault();
                return window.location = '/my-tasks';
            } else if (e.key == 'u') {
                e.preventDefault();
                return window.location = '/users';
            } else if (e.key == '/') {
                e.preventDefault();
                var search = document.querySelector('.search-input');
                return search ? search.focus() : null;
            };
        };
    });
};document.addEventListener('DOMContentLoaded', function () {
    setupFlashDismiss();
    setupAutofocus();
    setupSearch();
    __PS_MV_REG = [];
    return setupShortcuts();
});