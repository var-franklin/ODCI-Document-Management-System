document.addEventListener('DOMContentLoaded', function() {

    function updateTooltipPosition(menuItem, tooltip) {
        const rect = menuItem.getBoundingClientRect();
        const tooltipRect = tooltip.getBoundingClientRect();
        
        // Position tooltip to the right of the menu item
        const left = rect.right + 10; // 10px gap from sidebar
        const top = rect.top + (rect.height / 2) - (tooltipRect.height / 2);
        
        // Ensure tooltip doesn't go off screen
        const maxTop = window.innerHeight - tooltipRect.height - 10;
        const adjustedTop = Math.max(10, Math.min(top, maxTop));
        
        tooltip.style.left = left + 'px';
        tooltip.style.top = adjustedTop + 'px';
    }
    
    // Setup tooltip positioning for all sidebar menu items
    const sidebarMenuItems = document.querySelectorAll('#sidebar .side-menu li');
    
    sidebarMenuItems.forEach(menuItem => {
        const tooltip = menuItem.querySelector('.tooltip');
        if (tooltip) {
            // Show tooltip on mouse enter
            menuItem.addEventListener('mouseenter', function() {
                const sidebar = document.getElementById('sidebar');
                // Only show tooltip when sidebar is collapsed
                if (!sidebar.classList.contains('expanded')) {
                    updateTooltipPosition(menuItem, tooltip);
                    tooltip.classList.add('show');
                }
            });
            
            // Hide tooltip on mouse leave
            menuItem.addEventListener('mouseleave', function() {
                tooltip.classList.remove('show');
            });
        }
    });
    
    // Update tooltip positions on window resize
    window.addEventListener('resize', function() {
        const visibleTooltips = document.querySelectorAll('#sidebar .tooltip.show');
        visibleTooltips.forEach(tooltip => {
            const menuItem = tooltip.closest('li');
            if (menuItem) {
                updateTooltipPosition(menuItem, tooltip);
            }
        });
    });
});


// ======================================
// SIDEBAR FUNCTIONALITY
// ======================================

// Handle sidebar menu active states
const allSideMenu = document.querySelectorAll('#sidebar .side-menu.top li a');

allSideMenu.forEach(item => {
    const li = item.parentElement;

    item.addEventListener('click', function () {
        allSideMenu.forEach(i => {
            i.parentElement.classList.remove('active');
        });
        li.classList.add('active');
    });
});

// Toggle sidebar visibility - Updated Logic
const menuBar = document.querySelector('#content nav .bx.bx-menu');
const sidebar = document.getElementById('sidebar');

if (menuBar && sidebar) {
    menuBar.addEventListener('click', function () {
        // Toggle between collapsed (default) and expanded states
        sidebar.classList.toggle('expanded');
    });
}

// ======================================
// NAVBAR FUNCTIONALITY
// ======================================

// Handle navbar search functionality
const searchButton = document.querySelector('#content nav form .form-input button');
const searchButtonIcon = document.querySelector('#content nav form .form-input button .bx');
const searchForm = document.querySelector('#content nav form');

if (searchButton && searchButtonIcon && searchForm) {
    searchButton.addEventListener('click', function (e) {
        if(window.innerWidth < 576) {
            e.preventDefault();
            searchForm.classList.toggle('show');
            if(searchForm.classList.contains('show')) {
                searchButtonIcon.classList.replace('bx-search', 'bx-x');
            } else {
                searchButtonIcon.classList.replace('bx-x', 'bx-search');
            }
        }
    });
}

// Handle dark mode toggle
const switchModeToggle = document.getElementById('switch-mode');

if (switchModeToggle) {
    switchModeToggle.addEventListener('change', function () {
        if(this.checked) {
            document.body.classList.add('dark');
        } else {
            document.body.classList.remove('dark');
        }
    });
}

// ======================================
// RESPONSIVE FUNCTIONALITY
// ======================================

// Initial responsive setup
function initializeResponsive() {
    const sidebar = document.getElementById('sidebar');
    
    // Sidebar now starts collapsed by default (no class needed)
    // Just ensure it doesn't have the expanded class
    if (sidebar) {
        sidebar.classList.remove('expanded');
    }
    
    // Keep existing search form logic
    if(window.innerWidth > 576 && searchButtonIcon && searchForm) {
        searchButtonIcon.classList.replace('bx-x', 'bx-search');
        searchForm.classList.remove('show');
    }
}

// Handle window resize events
window.addEventListener('resize', function () {
    if(this.innerWidth > 576 && searchButtonIcon && searchForm) {
        searchButtonIcon.classList.replace('bx-x', 'bx-search');
        searchForm.classList.remove('show');
    }
});

// Initialize responsive behavior on load
initializeResponsive();

// ======================================
// UTILITY FUNCTIONS
// ======================================

// Function to set active sidebar menu item based on current page
function setActiveSidebarItem(pageName) {
    const allSideMenuItems = document.querySelectorAll('#sidebar .side-menu.top li');
    
    allSideMenuItems.forEach(item => {
        const link = item.querySelector('a');
        if (link && link.getAttribute('href').includes(pageName)) {
            item.classList.add('active');
        } else {
            item.classList.remove('active');
        }
    });
}

// Function to update page title in navbar
function updateNavbarTitle(title) {
    const pageTitle = document.getElementById('pageTitle');
    if (pageTitle) {
        pageTitle.textContent = title;
    }
}

// Function to update notification count
function updateNotificationCount(count) {
    const notificationCount = document.getElementById('notificationCount');
    if (notificationCount) {
        notificationCount.textContent = count;
        notificationCount.style.display = count > 0 ? 'flex' : 'none';
    }
}

// Function to update user avatar
function updateUserAvatar(avatarUrl) {
    const userAvatar = document.getElementById('userAvatar');
    if (userAvatar && avatarUrl) {
        userAvatar.src = avatarUrl;
    }
}

// ======================================
// EXPORT FUNCTIONS FOR OTHER MODULES
// ======================================

// Make utility functions available globally for other scripts
window.AppUtils = {
    setActiveSidebarItem: setActiveSidebarItem,
    updateNavbarTitle: updateNavbarTitle,
    updateNotificationCount: updateNotificationCount,
    updateUserAvatar: updateUserAvatar
};

const styleSheet = document.createElement('style');
styleSheet.textContent = tooltipStyles;
document.head.appendChild(styleSheet);










