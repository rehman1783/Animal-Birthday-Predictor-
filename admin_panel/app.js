/* =====================================================================
   ABP (Animal Birthday Predictor) — Owner Enterprise Admin Panel Engine
   100% Real-Time Supabase Database Integration & Multi-Tab Audit Ledger
   ===================================================================== */

// 1. Supabase Credentials
const SUPABASE_URL = "https://nqoushtsmytrecpguubq.supabase.co";
const SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5xb3VzaHRzbXl0cmVjcGd1dWJxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwOTQ2NjUsImV4cCI6MjEwMTY3MDY2NX0.-k5WrGjrBUj0eeSHqehpT-bB2QsV-F8aH1LME0ngEAY";

let supabaseClient = null;

// 2. Global State Variables
let activeTab = "overviewTab";
let allUsersData = [];
let filteredUsersData = [];
let certificatesLedgerData = [];
let animalsRegistryData = [];

let currentPage = 1;
const pageSize = 8;
let selectedUser = null;
let autoRefreshTimer = null;

// DOM Initialization
document.addEventListener("DOMContentLoaded", () => {
  initSupabase();
  setupNavigationTabs();
  setupEventListeners();
  loadRealtimeMasterData();
  
  // Auto-refresh real-time data every 10 seconds
  autoRefreshTimer = setInterval(() => {
    loadRealtimeMasterData(true);
  }, 10000);
});

// Initialize Supabase Client
function initSupabase() {
  try {
    if (window.supabase) {
      supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
      updateStatusIndicator("live", "Supabase Live DB", "Connected to PostgreSQL");
    } else {
      updateStatusIndicator("error", "SDK Loading...", "Supabase JS script missing");
    }
  } catch (err) {
    console.error("Supabase Client Initialization Error:", err);
    updateStatusIndicator("error", "Connection Error", err.message);
  }
}

function updateStatusIndicator(state, title, message) {
  const dot = document.getElementById("statusDot");
  const label = document.getElementById("statusLabel");
  const sub = document.getElementById("statusSub");

  if (state === "live") {
    dot.className = "status-indicator live";
    label.innerText = title || "Supabase Live DB";
    sub.innerText = message || "Connected & Syncing";
  } else if (state === "syncing") {
    dot.className = "status-indicator live";
    label.innerText = "Syncing Real-time...";
    sub.innerText = message || "Fetching DB updates";
  } else {
    dot.className = "status-indicator demo";
    label.innerText = title || "DB Offline";
    sub.innerText = message || "Check Network/Supabase";
  }
}

// Multi-Tab Navigation Handler
function setupNavigationTabs() {
  const navItems = document.querySelectorAll(".nav-item");
  
  navItems.forEach(item => {
    item.addEventListener("click", (e) => {
      e.preventDefault();
      const tabTarget = item.getAttribute("data-tab");
      if (!tabTarget) return;

      navItems.forEach(n => n.classList.remove("active"));
      item.classList.add("active");

      activeTab = tabTarget;
      updateHeaderTitles(tabTarget);

      // Hide all panes, show target pane
      document.querySelectorAll(".tab-pane").forEach(pane => {
        pane.classList.remove("active");
      });

      const activePane = document.getElementById(tabTarget);
      if (activePane) {
        activePane.classList.add("active");
      }
    });
  });
}

function updateHeaderTitles(tabId) {
  const title = document.getElementById("tabTitleHeader");
  const sub = document.getElementById("tabSubHeader");

  switch(tabId) {
    case "overviewTab":
      title.innerText = "Platform Performance & Real-Time Customer Overview";
      sub.innerText = "Live database analytics for user accounts, active subscription plans, certificate entitlements, and revenue.";
      break;
    case "usersTab":
    case "subscriptionsTab":
      title.innerText = "Customer Directory & Subscription Management";
      sub.innerText = "Complete searchable list of all registered horse & dog breeders with plan quota controls.";
      break;
    case "certificatesTab":
      title.innerText = "Issued PDF Certificates Audit Ledger";
      sub.innerText = "Audit trail of all foal, puppy, ultrasound, and foaling diary certificates generated on platform.";
      break;
    case "animalsTab":
      title.innerText = "Multi-Species Registered Animals Registry";
      sub.innerText = "All foundation stock registered across horse, dog, and cat breeders in Supabase.";
      break;
  }
}

// Setup Event Listeners
function setupEventListeners() {
  // Global search input
  document.getElementById("globalSearchInput").addEventListener("input", () => {
    filterAndRenderTable();
    renderCertificatesTable();
    renderAnimalsTable();
  });

  // Filters & Sorting
  document.getElementById("tierFilter").addEventListener("change", filterAndRenderTable);
  document.getElementById("statusFilter").addEventListener("change", filterAndRenderTable);
  document.getElementById("sortSelect").addEventListener("change", filterAndRenderTable);

  // Refresh button
  document.getElementById("refreshBtn").addEventListener("click", () => {
    loadRealtimeMasterData();
  });

  // Export CSV button
  document.getElementById("exportCsvBtn").addEventListener("click", exportActiveTabToCsv);

  // Pagination controls
  document.getElementById("prevPageBtn").addEventListener("click", () => {
    if (currentPage > 1) {
      currentPage--;
      renderTablePage();
    }
  });

  document.getElementById("nextPageBtn").addEventListener("click", () => {
    const maxPages = Math.ceil(filteredUsersData.length / pageSize);
    if (currentPage < maxPages) {
      currentPage++;
      renderTablePage();
    }
  });

  // Modal controls
  document.getElementById("closeModalBtn").addEventListener("click", closeModal);
  document.getElementById("cancelModalBtn").addEventListener("click", closeModal);
  document.getElementById("userEditForm").addEventListener("submit", handleSaveUserPlan);
  document.getElementById("addCreditsBtn").addEventListener("click", handleAddCredits);
}

// Master Real-Time Data Fetcher
async function loadRealtimeMasterData(isBackground = false) {
  if (!supabaseClient) {
    initSupabase();
    if (!supabaseClient) return;
  }

  if (!isBackground) {
    updateStatusIndicator("syncing", "Fetching DB...", "Querying Supabase RPCs");
  }

  try {
    // 1. User overview RPC
    const { data: usersOverview, error: usersErr } = await supabaseClient.rpc("get_admin_users_overview");
    if (!usersErr && usersOverview) {
      allUsersData = usersOverview;
    } else {
      await fetchDirectFromTables();
    }

    // 2. Stats overview RPC
    const { data: statsData, error: statsErr } = await supabaseClient.rpc("get_admin_dashboard_stats");
    if (!statsErr && statsData) {
      renderDashboardMetrics(statsData);
    } else {
      computeAndRenderMetrics(allUsersData);
    }

    // 3. Certificates audit ledger RPC
    const { data: certsData } = await supabaseClient.rpc("get_admin_certificates_ledger");
    if (certsData) {
      certificatesLedgerData = certsData;
    }

    // 4. Animals registry RPC
    const { data: animalsData } = await supabaseClient.rpc("get_admin_animals_registry");
    if (animalsData) {
      animalsRegistryData = animalsData;
    }

    updateStatusIndicator("live", "Supabase Live DB", `${allUsersData.length} Real Users Syncing`);

  } catch (err) {
    console.error("Master DB Fetch Error:", err);
    updateStatusIndicator("error", "DB Fetch Error", err.message);
  }

  filterAndRenderTable();
  renderCertificatesTable();
  renderAnimalsTable();
}

// Fallback direct tables fetcher
async function fetchDirectFromTables() {
  try {
    const { data: profiles } = await supabaseClient.from("profiles").select("*").order("created_at", { ascending: false });
    if (!profiles) { allUsersData = []; return; }

    const { data: subs } = await supabaseClient.from("user_subscriptions").select("*");
    const { data: certs } = await supabaseClient.from("certificate_entitlements").select("*");
    const { data: animals } = await supabaseClient.from("animals").select("user_id");

    const animalCountMap = {};
    if (animals) animals.forEach(a => { animalCountMap[a.user_id] = (animalCountMap[a.user_id] || 0) + 1; });

    const subMap = {};
    if (subs) subs.forEach(s => { subMap[s.user_id] = s; });

    const certMap = {};
    if (certs) certs.forEach(c => { certMap[c.user_id] = c; });

    allUsersData = profiles.map(p => {
      const s = subMap[p.id] || {};
      const c = certMap[p.id] || {};
      return {
        user_id: p.id,
        email: p.email,
        full_name: p.full_name || '',
        created_at: p.created_at,
        plan_tier: s.plan_tier || 'Free',
        status: s.status || 'active',
        billing_cycle: s.billing_cycle || 'monthly',
        price_paid: s.price_paid || 0.00,
        max_animal_quota: s.max_animal_quota || 1,
        expires_at: s.expires_at || null,
        total_certs_allocated: c.total_allocated || 5,
        certs_used: c.used_count || 0,
        animal_count: animalCountMap[p.id] || 0
      };
    });
  } catch (e) {
    allUsersData = [];
  }
}

// Render Overview KPI Metrics
function renderDashboardMetrics(stats) {
  const totalUsers = stats.total_users || 0;
  const activeSubs = stats.active_subscriptions || 0;
  const totalAnimals = stats.total_animals || 0;
  const totalCerts = stats.total_certificates || 0;
  const mrr = stats.estimated_mrr || 0;

  document.getElementById("kpiTotalUsers").innerText = totalUsers.toLocaleString();
  document.getElementById("kpiActiveSubs").innerText = activeSubs.toLocaleString();
  document.getElementById("kpiTotalAnimals").innerText = totalAnimals.toLocaleString();
  document.getElementById("kpiCertsIssued").innerText = totalCerts.toLocaleString();

  const convRate = totalUsers > 0 ? Math.round((activeSubs / totalUsers) * 100) : 0;
  document.getElementById("kpiSubsPaidRate").innerText = `${convRate}%`;

  const mrrStr = `$${Number(mrr).toLocaleString('en-US', { minimumFractionDigits: 2 })}`;
  document.getElementById("mrrBadge").innerHTML = `<i class="fa-solid fa-sack-dollar"></i> MRR: ${mrrStr}`;
  document.getElementById("summaryMrr").innerText = mrrStr;

  const arpu = totalUsers > 0 ? (mrr / totalUsers).toFixed(2) : "0.00";
  document.getElementById("arpuVal").innerText = `$${arpu}`;

  const avgCert = totalUsers > 0 ? (totalCerts / totalUsers).toFixed(1) : "0.0";
  document.getElementById("avgCertVal").innerText = avgCert;

  const pb = stats.plan_breakdown || { free: 0, basic: 0, pro: 0, enterprise: 0 };
  document.getElementById("countFree").innerText = `${pb.free || 0} Users`;
  document.getElementById("countBasic").innerText = `${pb.basic || 0} Users`;
  document.getElementById("countPro").innerText = `${pb.pro || 0} Users`;
  document.getElementById("countEnterprise").innerText = `${pb.enterprise || 0} Users`;

  const maxVal = Math.max(pb.free || 0, pb.basic || 0, pb.pro || 0, pb.enterprise || 0, 1);
  document.getElementById("barFree").style.width = `${((pb.free || 0) / maxVal) * 100}%`;
  document.getElementById("barBasic").style.width = `${((pb.basic || 0) / maxVal) * 100}%`;
  document.getElementById("barPro").style.width = `${((pb.pro || 0) / maxVal) * 100}%`;
  document.getElementById("barEnterprise").style.width = `${((pb.enterprise || 0) / maxVal) * 100}%`;
}

function computeAndRenderMetrics(users) {
  const freeCount = users.filter(u => u.plan_tier === 'Free').length;
  const basicCount = users.filter(u => u.plan_tier === 'Basic').length;
  const proCount = users.filter(u => u.plan_tier === 'Pro').length;
  const enterpriseCount = users.filter(u => u.plan_tier === 'Enterprise').length;
  const mrr = (basicCount * 19.00) + (proCount * 49.00) + (enterpriseCount * 149.00);

  renderDashboardMetrics({
    total_users: users.length,
    active_subscriptions: users.filter(u => u.status === 'active' && u.plan_tier !== 'Free').length,
    total_animals: users.reduce((acc, u) => acc + (u.animal_count || 0), 0),
    total_certificates: users.reduce((acc, u) => acc + (u.certs_used || 0), 0),
    estimated_mrr: mrr,
    plan_breakdown: { free: freeCount, basic: basicCount, pro: proCount, enterprise: enterpriseCount }
  });
}

// Filter and Sort Roster Table
function filterAndRenderTable() {
  const searchQuery = document.getElementById("globalSearchInput").value.toLowerCase().trim();
  const tierVal = document.getElementById("tierFilter").value;
  const statusVal = document.getElementById("statusFilter").value;
  const sortVal = document.getElementById("sortSelect").value;

  filteredUsersData = allUsersData.filter(user => {
    const matchSearch = !searchQuery ||
      (user.full_name && user.full_name.toLowerCase().includes(searchQuery)) ||
      (user.email && user.email.toLowerCase().includes(searchQuery)) ||
      (user.user_id && user.user_id.toLowerCase().includes(searchQuery));

    const matchTier = (tierVal === "ALL") || (user.plan_tier === tierVal);
    const matchStatus = (statusVal === "ALL") || (user.status === statusVal);

    return matchSearch && matchTier && matchStatus;
  });

  filteredUsersData.sort((a, b) => {
    if (sortVal === "newest") return new Date(b.created_at || 0) - new Date(a.created_at || 0);
    if (sortVal === "oldest") return new Date(a.created_at || 0) - new Date(b.created_at || 0);
    if (sortVal === "name") return (a.full_name || "").localeCompare(b.full_name || "");
    if (sortVal === "animals") return (b.animal_count || 0) - (a.animal_count || 0);
    if (sortVal === "certs") return (b.certs_used || 0) - (a.certs_used || 0);
    return 0;
  });

  currentPage = 1;
  renderTablePage();
}

function renderTablePage() {
  const tbody = document.getElementById("userTableBody");
  tbody.innerHTML = "";

  const total = filteredUsersData.length;
  if (total === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="8" style="text-align: center; padding: 40px; color: var(--text-muted);">
          <i class="fa-solid fa-database" style="font-size: 28px; margin-bottom: 12px; color: var(--accent-cyan); display: block;"></i>
          <strong>No Real Database Records Found</strong><br>
          <span style="font-size: 12px;">When users register in the app, their profiles and subscription tiers appear here instantly.</span>
        </td>
      </tr>
    `;
    document.getElementById("showingCountText").innerText = "Showing 0 of 0 users";
    document.getElementById("prevPageBtn").disabled = true;
    document.getElementById("nextPageBtn").disabled = true;
    return;
  }

  const startIdx = (currentPage - 1) * pageSize;
  const endIdx = Math.min(startIdx + pageSize, total);
  const pageItems = filteredUsersData.slice(startIdx, endIdx);

  pageItems.forEach(user => {
    const initials = getInitials(user.full_name || user.email);
    const dateStr = user.created_at ? new Date(user.created_at).toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }) : "N/A";
    
    const tierPillClass = `pill-tier-${(user.plan_tier || 'Free').toLowerCase()}`;
    const statusPillClass = `pill-status-${(user.status || 'active').toLowerCase()}`;

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>
        <div class="user-cell">
          <div class="table-avatar">${initials}</div>
          <div class="user-meta">
            <span class="user-name">${escapeHtml(user.full_name || 'Breeder Account')}</span>
            <span class="user-email">${escapeHtml(user.email || 'No email')}</span>
          </div>
        </div>
      </td>
      <td>
        <span class="pill ${tierPillClass}"><i class="fa-solid fa-crown"></i> ${user.plan_tier || 'Free'}</span>
      </td>
      <td>
        <span class="pill ${statusPillClass}"><i class="fa-solid fa-circle"></i> ${(user.status || 'active').toUpperCase()}</span>
      </td>
      <td><strong>${user.animal_count || 0}</strong> / ${user.max_animal_quota || 1} Animals</td>
      <td><strong>${user.certs_used || 0}</strong> / ${user.total_certs_allocated || 5} Credits</td>
      <td><span style="text-transform: capitalize;">${user.billing_cycle || 'monthly'}</span></td>
      <td>${dateStr}</td>
      <td class="text-right">
        <button class="btn btn-secondary btn-icon" onclick="openUserModal('${user.user_id}')" title="Manage Subscription & Quotas">
          <i class="fa-solid fa-sliders"></i> Manage
        </button>
      </td>
    `;
    tbody.appendChild(tr);
  });

  document.getElementById("showingCountText").innerText = `Showing ${startIdx + 1}–${endIdx} of ${total} users`;
  document.getElementById("currentPageNum").innerText = `Page ${currentPage}`;
  document.getElementById("prevPageBtn").disabled = currentPage === 1;
  document.getElementById("nextPageBtn").disabled = endIdx >= total;
}

// Render Certificates Ledger Table
function renderCertificatesTable() {
  const tbody = document.getElementById("certsTableBody");
  if (!tbody) return;
  tbody.innerHTML = "";

  const query = document.getElementById("globalSearchInput").value.toLowerCase().trim();
  const certs = certificatesLedgerData.filter(c => {
    return !query || 
      (c.certificate_id && c.certificate_id.toLowerCase().includes(query)) ||
      (c.target_name && c.target_name.toLowerCase().includes(query)) ||
      (c.user_email && c.user_email.toLowerCase().includes(query));
  });

  if (certs.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="5" style="text-align: center; padding: 32px; color: var(--text-muted);">
          No issued certificates found in audit log.
        </td>
      </tr>
    `;
    return;
  }

  certs.forEach(c => {
    const dateStr = c.issued_at ? new Date(c.issued_at).toLocaleString() : "N/A";
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><strong style="color: var(--accent-gold);">${escapeHtml(c.certificate_id)}</strong></td>
      <td><span class="badge badge-cyan" style="text-transform: uppercase;">${escapeHtml(c.certificate_type)}</span></td>
      <td><strong>${escapeHtml(c.target_name || 'N/A')}</strong></td>
      <td>${escapeHtml(c.user_name || c.user_email)} (${escapeHtml(c.user_email)})</td>
      <td>${dateStr}</td>
    `;
    tbody.appendChild(tr);
  });
}

// Render Animals Registry Table
function renderAnimalsTable() {
  const tbody = document.getElementById("animalsTableBody");
  if (!tbody) return;
  tbody.innerHTML = "";

  const query = document.getElementById("globalSearchInput").value.toLowerCase().trim();
  const animals = animalsRegistryData.filter(a => {
    return !query || 
      (a.name && a.name.toLowerCase().includes(query)) ||
      (a.species && a.species.toLowerCase().includes(query)) ||
      (a.breed && a.breed.toLowerCase().includes(query)) ||
      (a.owner_email && a.owner_email.toLowerCase().includes(query));
  });

  if (animals.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="7" style="text-align: center; padding: 32px; color: var(--text-muted);">
          No registered foundation stock animals found.
        </td>
      </tr>
    `;
    return;
  }

  animals.forEach(a => {
    const dateStr = a.created_at ? new Date(a.created_at).toLocaleDateString() : "N/A";
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td><strong>${escapeHtml(a.name)}</strong></td>
      <td><span class="pill pill-tier-basic">${escapeHtml(a.species || 'Horse')}</span></td>
      <td>${escapeHtml(a.breed || 'Standard')}</td>
      <td>${escapeHtml(a.sex || 'N/A')}</td>
      <td>${escapeHtml(a.microchip_number || a.registration_number || 'N/A')}</td>
      <td>${escapeHtml(a.owner_name || a.owner_email)}</td>
      <td>${dateStr}</td>
    `;
    tbody.appendChild(tr);
  });
}

// User Modal Logic
window.openUserModal = function(userId) {
  selectedUser = allUsersData.find(u => u.user_id === userId);
  if (!selectedUser) return;

  document.getElementById("modalUserId").value = selectedUser.user_id;
  document.getElementById("modalUserName").innerText = selectedUser.full_name || "Breeder Account";
  document.getElementById("modalUserEmail").innerText = selectedUser.email || "";
  document.getElementById("modalAvatar").innerText = getInitials(selectedUser.full_name || selectedUser.email);

  document.getElementById("modalPlanTier").value = selectedUser.plan_tier || "Free";
  document.getElementById("modalStatus").value = selectedUser.status || "active";
  document.getElementById("modalAnimalQuota").value = selectedUser.max_animal_quota || 1;

  document.getElementById("modalAnimalCount").innerText = selectedUser.animal_count || 0;
  document.getElementById("modalCertsUsed").innerText = selectedUser.certs_used || 0;
  document.getElementById("modalCertsTotal").innerText = selectedUser.total_certs_allocated || 5;

  document.getElementById("userEditModal").classList.add("active");
};

function closeModal() {
  document.getElementById("userEditModal").classList.remove("active");
  selectedUser = null;
}

// Save Plan Changes
async function handleSaveUserPlan(e) {
  e.preventDefault();
  if (!selectedUser || !supabaseClient) return;

  const newTier = document.getElementById("modalPlanTier").value;
  const newStatus = document.getElementById("modalStatus").value;
  const newQuota = parseInt(document.getElementById("modalAnimalQuota").value) || 1;

  try {
    const { error } = await supabaseClient.rpc("admin_update_user_subscription", {
      target_user_id: selectedUser.user_id,
      new_plan_tier: newTier,
      new_status: newStatus,
      new_quota: newQuota
    });

    if (error) {
      alert("Failed to update database subscription: " + error.message);
      return;
    }

    selectedUser.plan_tier = newTier;
    selectedUser.status = newStatus;
    selectedUser.max_animal_quota = newQuota;

    loadRealtimeMasterData();
    closeModal();
  } catch (err) {
    alert("Database connection error: " + err.message);
  }
}

// Add Certificate Credits
async function handleAddCredits() {
  if (!selectedUser || !supabaseClient) return;
  const creditsToAdd = parseInt(document.getElementById("modalAddCertCredits").value) || 5;

  try {
    const { error } = await supabaseClient.rpc("admin_adjust_certificate_credits", {
      target_user_id: selectedUser.user_id,
      credits_to_add: creditsToAdd
    });

    if (error) {
      alert("Failed to adjust credits: " + error.message);
      return;
    }

    selectedUser.total_certs_allocated = (selectedUser.total_certs_allocated || 5) + creditsToAdd;
    document.getElementById("modalCertsTotal").innerText = selectedUser.total_certs_allocated;

    loadRealtimeMasterData();
  } catch (err) {
    alert("Database connection error: " + err.message);
  }
}

// Export Active Tab to CSV
function exportActiveTabToCsv() {
  if (activeTab === "certificatesTab") {
    exportCertificatesToCsv();
  } else if (activeTab === "animalsTab") {
    exportAnimalsToCsv();
  } else {
    exportUsersToCsv();
  }
}

function exportUsersToCsv() {
  if (filteredUsersData.length === 0) {
    alert("No real user records in database to export.");
    return;
  }
  const headers = ["User ID", "Full Name", "Email", "Plan Tier", "Status", "Billing Cycle", "Price Paid ($)", "Animal Quota", "Animals Count", "Certificates Used", "Certificates Allocated", "Joined Date"];
  const csvRows = [headers.join(",")];
  filteredUsersData.forEach(u => {
    csvRows.push([
      `"${u.user_id}"`, `"${u.full_name || ''}"`, `"${u.email || ''}"`, `"${u.plan_tier || 'Free'}"`,
      `"${u.status || 'active'}"`, `"${u.billing_cycle || 'monthly'}"`, u.price_paid || 0.00,
      u.max_animal_quota || 1, u.animal_count || 0, u.certs_used || 0, u.total_certs_allocated || 5,
      `"${u.created_at ? new Date(u.created_at).toISOString() : ''}"`
    ].join(","));
  });
  downloadCsvFile(csvRows.join("\n"), `ABP_Users_Roster_${new Date().toISOString().slice(0, 10)}.csv`);
}

function exportCertificatesToCsv() {
  if (certificatesLedgerData.length === 0) {
    alert("No certificate audit records to export.");
    return;
  }
  const headers = ["Certificate ID", "Type", "Target Name", "User Email", "User Name", "Issued Timestamp"];
  const csvRows = [headers.join(",")];
  certificatesLedgerData.forEach(c => {
    csvRows.push([
      `"${c.certificate_id}"`, `"${c.certificate_type}"`, `"${c.target_name || ''}"`,
      `"${c.user_email || ''}"`, `"${c.user_name || ''}"`, `"${c.issued_at || ''}"`
    ].join(","));
  });
  downloadCsvFile(csvRows.join("\n"), `ABP_Certificates_Ledger_${new Date().toISOString().slice(0, 10)}.csv`);
}

function exportAnimalsToCsv() {
  if (animalsRegistryData.length === 0) {
    alert("No animal registry records to export.");
    return;
  }
  const headers = ["Animal ID", "Name", "Species", "Breed", "Sex", "Microchip/Reg Number", "Owner Email", "Owner Name", "Created Date"];
  const csvRows = [headers.join(",")];
  animalsRegistryData.forEach(a => {
    csvRows.push([
      `"${a.id}"`, `"${a.name}"`, `"${a.species || ''}"`, `"${a.breed || ''}"`, `"${a.sex || ''}"`,
      `"${a.microchip_number || a.registration_number || ''}"`, `"${a.owner_email || ''}"`, `"${a.owner_name || ''}"`, `"${a.created_at || ''}"`
    ].join(","));
  });
  downloadCsvFile(csvRows.join("\n"), `ABP_Animals_Registry_${new Date().toISOString().slice(0, 10)}.csv`);
}

function downloadCsvFile(csvString, filename) {
  const blob = new Blob([csvString], { type: "text/csv;charset=utf-8;" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.setAttribute("href", url);
  link.setAttribute("download", filename);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// Utility Helpers
function getInitials(nameOrEmail) {
  if (!nameOrEmail) return "U";
  const parts = nameOrEmail.trim().split(" ");
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase();
  return nameOrEmail.substring(0, 2).toUpperCase();
}

function escapeHtml(str) {
  return String(str || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}
