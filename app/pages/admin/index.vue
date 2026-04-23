<template>
  <main class="page">
    <div class="container">
      <ClientOnly>
        <div
          v-if="!isAdmin"
          class="empty-state"
        >
          <ShieldExclamationIcon
            class="empty-icon"
            aria-hidden="true"
          />
          <h2>Access Denied</h2>
          <p>You don't have admin privileges. If you just updated your role, try refreshing.</p>
          <div style="display: flex; gap: 10px; justify-content: center; margin-top: 20px;">
            <button
              class="btn btn-outline"
              :disabled="refreshing"
              @click="refreshRole"
            >
              {{ refreshing ? 'Checking...' : 'Retry Permission Check' }}
            </button>
            <NuxtLink
              to="/"
              class="btn btn-primary"
            >Go Home</NuxtLink>
          </div>
        </div>

        <!-- Admin content -->
        <template v-else-if="isAdmin">
          <div class="page-header">
            <div>
              <div style="display:flex; align-items:center; gap: 12px;">
                <h1 class="page-title">
                  Admin Panel
                </h1>
                <label style="display:flex; align-items:center; gap:8px; font-size:0.85rem; color: var(--muted); cursor:pointer; background: var(--surface); padding: 4px 10px; border-radius: 99px; border: 1px solid var(--border);">
                  <input type="checkbox" v-model="maskAsStaff" style="accent-color: var(--red);">
                  Post actions as "Staff"
                </label>
                <Transition name="fade">
                  <span
                    v-if="savingItem"
                    class="text-muted"
                    style="font-size: 0.8rem; background: var(--surface); padding: 4px 10px; border-radius: 99px; border: 1px solid var(--border);"
                  >Saving...</span>
                  <span
                    v-else-if="savedItem"
                    style="font-size: 0.8rem; background: rgba(16,185,129,0.1); color: #10b981; padding: 4px 10px; border-radius: 99px; font-weight: bold;"
                  >✔ Saved changes</span>
                </Transition>
              </div>
              <p class="page-sub">
                Manage jobs and review applications.
              </p>
            </div>
          </div>

          <!-- Tabs -->
          <div class="tabs">
            <button
              :class="['tab', { active: activeTab === 'jobs' }]"
              @click="activeTab = 'jobs'"
            >
              <BriefcaseIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Jobs ({{ allJobs.length }})
            </button>
            <button
              :class="['tab', { active: activeTab === 'applications' }]"
              @click="activeTab = 'applications'"
            >
              <ClipboardDocumentListIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Applications ({{ allApplications.length }})
            </button>
            <button
              v-if="permissions?.can_post_announcements"
              :class="['tab', { active: activeTab === 'announcements' }]"
              @click="activeTab = 'announcements'"
            >
              <MegaphoneIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Announcements
            </button>
            <button
              v-if="permissions?.can_send_notifications"
              :class="['tab', { active: activeTab === 'notifications' }]"
              @click="activeTab = 'notifications'"
            >
              <BellAlertIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Notifications
            </button>
            <button
              v-if="permissions?.can_manage_staff"
              :class="['tab', { active: activeTab === 'staff' }]"
              @click="activeTab = 'staff'"
            >
              <UsersIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Staff
            </button>
            <button
              v-if="permissions?.can_manage_staff || permissions?.can_ban_users"
              :class="['tab', { active: activeTab === 'accounts' }]"
              @click="activeTab = 'accounts'; if (allAccounts.length === 0) fetchAllAccounts()"
            >
              <UserGroupIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Accounts
            </button>
            <button
              v-if="permissions?.can_manage_notices"
              :class="['tab', { active: activeTab === 'notices' }]"
              @click="activeTab = 'notices'"
            >
              <InformationCircleIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Notices
            </button>
            <button
              v-if="permissions?.can_ban_users"
              :class="['tab', { active: activeTab === 'blacklists' }]"
              @click="activeTab = 'blacklists'"
            >
              <NoSymbolIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Blacklist
            </button>
            <button
              :class="['tab', { active: activeTab === 'advanced' }]"
              @click="activeTab = 'advanced'"
            >
              <Cog6ToothIcon
                class="tab-icon"
                aria-hidden="true"
              />
              Advanced
            </button>
          </div>

          <!-- ═══ JOBS TAB ═══ -->
          <div v-if="activeTab === 'jobs'">
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Open Jobs
                </h2>
                <p class="section-sub">
                  Manage active job postings for Sunshine Studio.
                </p>
              </div>
              <div
                v-if="permissions?.can_manage_jobs"
                class="toolbar"
              >
                <NuxtLink
                  to="/admin/jobs/create"
                  class="btn btn-primary"
                >
                  <PlusIcon class="btn-icon" /> Create Job
                </NuxtLink>
              </div>
            </div>

            <div
              v-if="loadingJobs && allJobs.length === 0"
              class="loading-state"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingJobs }]"
            >
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Job Title</th>
                    <th>Status</th>
                    <th>Created</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="job in allJobs"
                    :key="job.id"
                  >
                    <td class="td-title">
                      {{ job.title }}
                    </td>
                    <td>
                      <span :class="['active-badge', { inactive: !job.is_active }]">
                        {{ job.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td>{{ formatDate(job.created_at) }}</td>
                    <td class="td-actions">
                      <template v-if="permissions?.can_manage_jobs">
                        <NuxtLink
                          :to="`/admin/jobs/${job.id}`"
                          class="action-btn"
                          title="Edit"
                        >
                          <PencilIcon
                            class="action-icon"
                            aria-hidden="true"
                          />
                        </NuxtLink>
                        <button
                          class="action-btn action-toggle"
                          title="Toggle Active"
                          @click="toggleJobActive(job)"
                        >
                          <EyeIcon
                            v-if="job.is_active"
                            class="action-icon"
                            aria-hidden="true"
                          />
                          <EyeSlashIcon
                            v-if="!job.is_active"
                            class="action-icon"
                            aria-hidden="true"
                          />
                        </button>
                        <button
                          class="action-btn action-delete"
                          title="Delete"
                          @click="deleteJob(job)"
                        >
                          <TrashIcon
                            class="action-icon"
                            aria-hidden="true"
                          />
                        </button>
                      </template>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ APPLICATIONS TAB ═══ -->
          <div
            v-if="activeTab === 'applications'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Job Applications
                </h2>
                <p class="section-sub">
                  Review and manage candidate submissions.
                </p>
              </div>

              <div class="admin-stats">
                <div class="stat-mini">
                  <span class="stat-mini-label">Total</span>
                  <span class="stat-mini-val">{{ allApplications.length }}</span>
                </div>
                <div class="stat-mini">
                  <span class="stat-mini-label text-red">AI Flagged</span>
                  <span class="stat-mini-val text-red">{{ allApplications.filter(a => a.ai_flagged).length }}</span>
                </div>
              </div>
            </div>

            <div class="toolbar">
              <div class="filter-tags">
                <button
                  v-for="s in ['all', 'pending', 'reviewing', 'accepted', 'rejected']"
                  :key="s"
                  :class="['filter-tag', { active: appFilter === s }]"
                  @click="appFilter = s"
                >
                  {{ s }}
                </button>
              </div>
            </div>

            <div
              v-if="loadingApps && allApplications.length === 0"
              class="loading-state"
            >
              <div class="spinner" />
            </div>

            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingApps }]"
            >
              <table class="data-table">
                <thead>
                  <tr>
                    <th>Applicant</th>
                    <th>Position</th>
                    <th>Status</th>
                    <th>Risk</th>
                    <th>Applied</th>
                    <th>Rating</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="app in filteredApplications"
                    :key="app.id"
                  >
                    <td>
                      <div class="applicant-cell">
                        <img
                          v-if="app.discord_avatar"
                          :src="app.discord_avatar"
                          :alt="app.discord_username"
                          class="applicant-avatar"
                        >
                        <div
                          v-else
                          class="avatar-placeholder"
                        >
                          {{ (app.discord_username || '?')[0] }}
                        </div>
                        <span class="applicant-name">{{ app.discord_username || 'Unknown' }}</span>
                      </div>
                    </td>
                    <td>{{ app.jobs?.title || '—' }}</td>
                    <td>
                      <select
                        :value="app.status"
                        class="status-select"
                        @change="updateApplicationStatus(app, $event.target.value)"
                      >
                        <option value="pending">
                          Pending
                        </option>
                        <option value="reviewing">
                          Reviewing
                        </option>
                        <option value="accepted">
                          Accepted
                        </option>
                        <option value="rejected">
                          Rejected
                        </option>
                      </select>
                    </td>
                    <td>
                      <span
                        v-if="app.ai_flagged"
                        class="tag-ai-flagged"
                      >Flagged</span>
                      <span
                        v-else
                        class="tag-ai-clear"
                        style="opacity:0.5"
                      >Clear</span>
                    </td>
                    <td>{{ formatDate(app.created_at) }}</td>
                    <td>
                      <div class="rating-stars">
                        <button
                          v-for="star in 5"
                          :key="star"
                          :class="['star-btn', { filled: star <= (app.rating || 0) }]"
                          :title="`Rate ${star}/5`"
                          @click="rateApplication(app, star)"
                        >
                          ★
                        </button>
                      </div>
                    </td>
                    <td class="td-actions">
                      <NuxtLink
                        :to="`/admin/application/${app.id}`"
                        class="action-btn"
                        title="Full Review"
                      >
                        <DocumentMagnifyingGlassIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </NuxtLink>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ ANNOUNCEMENTS TAB ═══ -->
          <div
            v-if="activeTab === 'announcements'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Live Announcements
                </h2>
                <p class="section-sub">
                  Post line updates or alerts to the homepage.
                </p>
              </div>
              <form
                class="toolbar"
                style="gap:10px;"
                @submit.prevent="postAnnouncement"
              >
                <input
                  v-model="newAnnouncement.title"
                  class="form-input"
                  placeholder="Title (e.g. Server Update)"
                  required
                >
                <input
                  v-model="newAnnouncement.content"
                  class="form-input"
                  placeholder="Message content"
                  required
                  style="width:300px"
                >
                <button
                  type="submit"
                  class="btn btn-primary btn-sm"
                  :disabled="savingItem"
                >
                  Post Update
                </button>
              </form>
            </div>
            <div
              v-if="loadingAnnouncements && allAnnouncements.length === 0"
              class="loading-state"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingAnnouncements }]"
            >
              <table class="data-table">
                <thead><tr><th>Title</th><th>Content</th><th>Author</th><th>Status</th><th>Date</th><th>Action</th></tr></thead>
                <tbody>
                  <tr
                    v-for="ann in allAnnouncements"
                    :key="ann.id"
                  >
                    <td class="td-title">
                      {{ ann.title }}
                    </td>
                    <td>{{ ann.content }}</td>
                    <td><span class="author-tag">{{ ann.author_name || 'System' }}</span></td>
                    <td>
                      <span :class="['active-badge', { inactive: !ann.is_active }]">
                        {{ ann.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td>{{ formatDate(ann.created_at) }}</td>
                    <td class="td-actions">
                      <button
                        class="action-btn action-toggle"
                        title="Toggle Status"
                        @click="toggleAnnouncement(ann)"
                      >
                        <EyeSlashIcon
                          v-if="ann.is_active"
                          class="action-icon"
                          aria-hidden="true"
                        />
                        <EyeIcon
                          v-else
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                      <button
                        class="action-btn action-delete"
                        title="Delete"
                        @click="deleteAnnouncement(ann.id)"
                      >
                        <TrashIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ NOTIFICATIONS TAB ═══ -->
          <div
            v-if="activeTab === 'notifications'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Send Notifications
                </h2>
                <p class="section-sub">
                  Send messages directly to users' notification inbox.
                </p>
              </div>
            </div>

            <div class="compose-card">
              <h3 class="compose-title">
                ✉ Compose Notification
              </h3>
              <form
                class="compose-form"
                @submit.prevent="sendNotification"
              >
                <div class="form-grid">
                  <div class="form-group">
                    <label>Title</label>
                    <input
                      v-model="notifForm.title"
                      class="form-input"
                      placeholder="Notification title"
                      required
                    >
                  </div>
                  <div class="form-group">
                    <label>Type</label>
                    <select
                      v-model="notifForm.type"
                      class="form-input"
                    >
                      <option value="info">
                        ℹ️ Info
                      </option>
                      <option value="warning">
                        ⚠️ Warning
                      </option>
                      <option value="urgent">
                        🔴 Urgent
                      </option>
                      <option value="application_notice">
                        📋 Application Notice
                      </option>
                    </select>
                  </div>
                </div>
                <div class="form-group form-full">
                  <label>Message</label>
                  <textarea
                    v-model="notifForm.message"
                    class="form-textarea"
                    rows="3"
                    placeholder="Write your notification message..."
                    required
                  />
                </div>
                <div class="form-grid">
                  <div class="form-group">
                    <label>Target Audience</label>
                    <select
                      v-model="notifForm.target"
                      class="form-input"
                    >
                      <option value="all">
                        All Users
                      </option>
                      <option value="specific">
                        Specific User (Discord ID)
                      </option>
                      <option value="status_pending">
                        Users with Pending Applications
                      </option>
                      <option value="status_reviewing">
                        Users with Reviewing Applications
                      </option>
                      <option value="status_accepted">
                        Users with Accepted Applications
                      </option>
                      <option value="status_rejected">
                        Users with Rejected Applications
                      </option>
                    </select>
                  </div>
                  <div
                    v-if="notifForm.target === 'specific'"
                    class="form-group"
                  >
                    <label>Discord ID or Profile UUID</label>
                    <input
                      v-model="notifForm.targetId"
                      class="form-input"
                      placeholder="Enter Discord ID or UUID"
                    >
                  </div>
                </div>
                <div class="form-group form-full">
                  <label>Link (optional)</label>
                  <input
                    v-model="notifForm.link"
                    class="form-input"
                    placeholder="e.g. /applications or /jobs"
                  >
                </div>
                <div style="display:flex; align-items:center; gap:12px; margin-top:8px;">
                  <button
                    type="submit"
                    class="btn btn-primary"
                    :disabled="sendingNotif"
                  >
                    {{ sendingNotif ? 'Sending...' : '📤 Send Notification' }}
                  </button>
                  <span
                    v-if="notifSent"
                    style="color:#10b981; font-weight:700; font-size:0.85rem;"
                  >✔ Notification sent!</span>
                  <span
                    v-if="notifError"
                    style="color:#ef4444; font-weight:600; font-size:0.85rem;"
                  >{{ notifError }}</span>
                </div>
              </form>
            </div>

            <h3
              class="section-title"
              style="margin-top:40px;"
            >
              Recently Sent
              <button
                class="btn btn-outline btn-sm"
                style="margin-left: 12px; font-size: 0.75rem; padding: 4px 8px;"
                @click="fetchSentNotifications"
              >
                ↻ Refresh
              </button>
            </h3>
            <div
              v-if="loadingSentNotifs && sentNotifications.length === 0"
              class="loading-state"
            >
              <div class="spinner" />
            </div>
            <div
              v-else-if="sentNotifications.length === 0"
              class="empty-state"
              style="padding:30px;"
            >
              <p>No notifications sent yet.</p>
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingSentNotifs }]"
            >
              <table class="data-table">
                <thead><tr><th>Title</th><th>Message</th><th>Type</th><th>Sent By</th><th>Date</th></tr></thead>
                <tbody>
                  <tr
                    v-for="n in sentNotifications"
                    :key="n.id"
                  >
                    <td class="td-title">
                      {{ n.title }}
                    </td>
                    <td style="max-width:300px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                      {{ n.message }}
                    </td>
                    <td><span :class="['type-badge', `type-${n.type || n.category || 'system'}`]">{{ n.type || n.category || 'system' }}</span></td>
                    <td><span class="author-tag">{{ n.actual_author ? `${n.actual_author} (as ${n.sent_by_name})` : (n.sent_by_name || 'System') }}</span></td>
                    <td>{{ formatDate(n.created_at) }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ ACCOUNTS TAB ═══ -->
          <div
            v-if="activeTab === 'accounts'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  All Accounts
                </h2>
                <p class="section-sub">
                  View and manage all registered platform users.
                </p>
              </div>
              <div class="toolbar">
                <input
                  v-model="accountsSearch"
                  class="form-input"
                  placeholder="Search by username or ID..."
                >
                <button
                  class="btn btn-outline btn-sm"
                  @click="fetchAllAccounts"
                >
                  ↻ Refresh
                </button>
              </div>
            </div>

            <div
              v-if="loadingAccounts"
              class="loading-state"
              style="margin-top:30px;"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingAccounts }]"
              style="margin-top:30px;"
            >
              <table class="data-table">
                <thead><tr><th>User</th><th>Discord ID</th><th>Role</th><th>Joined</th><th>Actions</th></tr></thead>
                <tbody>
                  <tr
                    v-for="acc in filteredAccounts"
                    :key="acc.id"
                  >
                    <td>
                      <div class="applicant-cell">
                        <img
                          v-if="acc.discord_avatar"
                          :src="acc.discord_avatar"
                          class="applicant-avatar"
                        >
                        <div
                          v-else
                          class="avatar-placeholder"
                        >
                          {{ (acc.discord_username || '?')[0] }}
                        </div>
                        <span class="applicant-name">
                          {{ acc.discord_username || 'Unknown' }}
                          <span
                            v-if="acc.is_banned"
                            class="staff-role-badge"
                            style="margin-left: 8px; background:#ef4444;"
                          >Banned</span>
                        </span>
                      </div>
                    </td>
                    <td><code style="font-size:0.75rem; background:var(--bg-alt); padding:2px 6px; border-radius:4px;">{{ acc.discord_id || '—' }}</code></td>
                    <td>
                      <span
                        v-if="acc.discord_username === 'derkloking'"
                        class="staff-role-badge role-owner"
                      >Owner</span>
                      <span
                        v-else-if="acc.staff_role"
                        class="dept-tag"
                      >{{ acc.staff_role }}</span>
                      <span
                        v-else-if="acc.role === 'admin'"
                        class="dept-tag"
                      >legacy admin</span>
                      <span
                        v-else
                        style="color:var(--muted); font-size:0.8rem;"
                      >user</span>
                    </td>
                    <td>{{ formatDate(acc.created_at) }}</td>
                    <td class="td-actions">
                      <button
                        v-if="permissions?.can_ban_users && acc.discord_username !== 'derkloking' && !acc.is_banned"
                        class="action-btn action-delete"
                        title="Ban User"
                        @click="banSpecificUser(acc.id, acc.discord_username)"
                      >
                        <NoSymbolIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                      <button
                        v-if="permissions?.can_ban_users && acc.is_banned"
                        class="action-btn action-toggle"
                        title="Unban"
                        @click="unbanSpecificUser(acc.id)"
                      >
                        <ArrowUturnLeftIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ STAFF TAB ═══ -->
          <div
            v-if="activeTab === 'staff'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Staff Management
                </h2>
                <p class="section-sub">
                  Manage your team — admins, moderators, and staff members.
                </p>
              </div>
            </div>

            <div class="compose-card">
              <h3 class="compose-title">
                ➕ Add Staff Member
              </h3>
              <form
                class="compose-form"
                @submit.prevent="addStaff"
              >
                <div class="form-grid">
                  <div class="form-group">
                    <label>Discord ID or Profile UUID</label>
                    <input
                      v-model="staffForm.userId"
                      class="form-input"
                      placeholder="Enter Discord ID or UUID"
                      required
                    >
                  </div>
                  <div class="form-group">
                    <label>Role</label>
                    <select
                      v-model="staffForm.role"
                      class="form-input"
                    >
                      <option value="admin">
                        Admin
                      </option>
                      <option value="moderator">
                        Moderator
                      </option>
                      <option value="staff">
                        Staff
                      </option>
                    </select>
                  </div>
                </div>
                <div style="display:flex; align-items:center; gap:12px; margin-top:8px;">
                  <button
                    type="submit"
                    class="btn btn-primary"
                    :disabled="addingStaff"
                  >
                    {{ addingStaff ? 'Adding...' : 'Add Staff' }}
                  </button>
                  <span
                    v-if="staffAdded"
                    style="color:#10b981; font-weight:700; font-size:0.85rem;"
                  >✔ Staff member added!</span>
                  <span
                    v-if="staffError"
                    style="color:#ef4444; font-weight:600; font-size:0.85rem;"
                  >{{ staffError }}</span>
                </div>
              </form>
            </div>

            <div
              v-if="loadingStaff && allStaff.length === 0"
              class="loading-state"
              style="margin-top:30px;"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingStaff }]"
              style="margin-top:30px;"
            >
              <table class="data-table">
                <thead><tr><th>Member</th><th>Discord ID</th><th>Staff Role</th><th>Joined</th><th>Actions</th></tr></thead>
                <tbody>
                  <tr
                    v-for="s in allStaff"
                    :key="s.id"
                  >
                    <td>
                      <div class="applicant-cell">
                        <img
                          v-if="s.discord_avatar"
                          :src="s.discord_avatar"
                          :alt="s.discord_username"
                          class="applicant-avatar"
                        >
                        <div
                          v-else
                          class="avatar-placeholder"
                        >
                          {{ (s.discord_username || '?')[0] }}
                        </div>
                        <span class="applicant-name">
                          {{ s.discord_username || 'Unknown' }}
                          <span
                            v-if="s.discord_username === 'derkloking'"
                            class="staff-role-badge role-owner"
                            style="margin-left: 8px;"
                          >System Owner</span>
                        </span>
                      </div>
                    </td>
                    <td><code style="font-size:0.75rem; background:var(--bg-alt); padding:2px 6px; border-radius:4px;">{{ s.discord_id || '—' }}</code></td>
                    <td>
                      <div style="display:flex; flex-direction:column; gap:6px;">
                        <select
                          :value="s.staff_role || s.role"
                          class="status-select"
                          style="width: fit-content; margin-bottom: 4px;"
                          :disabled="s.discord_username === 'derkloking'"
                          @change="changeStaffRole(s, $event.target.value)"
                        >
                          <option
                            value="owner"
                            disabled
                          >
                            Owner
                          </option>
                          <option value="admin">
                            Admin
                          </option>
                          <option value="moderator">
                            Moderator
                          </option>
                          <option value="staff">
                            Staff
                          </option>
                          <option
                            value="banned"
                            class="text-red"
                          >
                            Ban / Blacklist
                          </option>
                        </select>

                        <div
                          v-if="s.discord_username !== 'derkloking'"
                          class="permission-toggles"
                          style="font-size:0.75rem; display:grid; grid-template-columns: 1fr 1fr; gap:4px; max-width: 250px;"
                        >
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_manage_jobs"
                            @change="updateStaffPermission(s, 'can_manage_jobs', $event.target.checked)"
                          > Jobs</label>
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_manage_staff"
                            @change="updateStaffPermission(s, 'can_manage_staff', $event.target.checked)"
                          > Staff</label>
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_manage_notices"
                            @change="updateStaffPermission(s, 'can_manage_notices', $event.target.checked)"
                          > Notices</label>
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_post_announcements"
                            @change="updateStaffPermission(s, 'can_post_announcements', $event.target.checked)"
                          > Announces</label>
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_send_notifications"
                            @change="updateStaffPermission(s, 'can_send_notifications', $event.target.checked)"
                          > Notify</label>
                          <label class="perm-label"><input
                            type="checkbox"
                            :checked="s.can_ban_users"
                            @change="updateStaffPermission(s, 'can_ban_users', $event.target.checked)"
                          > Bans</label>
                        </div>
                        <div
                          v-else
                          style="font-size: 0.75rem; color: var(--muted); font-style: italic;"
                        >
                          All permissions automatically granted.
                        </div>
                      </div>
                    </td>
                    <td style="vertical-align: top;">
                      {{ formatDate(s.created_at) }}
                    </td>
                    <td
                      class="td-actions"
                      style="vertical-align: top;"
                    >
                      <button
                        v-if="s.discord_username !== 'derkloking'"
                        class="action-btn action-delete"
                        title="Remove Staff"
                        @click="removeStaff(s)"
                      >
                        <TrashIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ NOTICES TAB ═══ -->
          <div
            v-if="activeTab === 'notices'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Application Notices
                </h2>
                <p class="section-sub">
                  Post notices visible to applicants, e.g. "Results will be out on XX.XX.XXXX".
                </p>
              </div>
            </div>

            <div class="compose-card">
              <h3 class="compose-title">
                📋 New Application Notice
              </h3>
              <form
                class="compose-form"
                @submit.prevent="postNotice"
              >
                <div class="form-grid">
                  <div class="form-group">
                    <label>Title</label>
                    <input
                      v-model="noticeForm.title"
                      class="form-input"
                      placeholder="e.g. Application Results Date"
                      required
                    >
                  </div>
                  <div class="form-group">
                    <label>Target</label>
                    <select
                      v-model="noticeForm.target"
                      class="form-input"
                    >
                      <option value="all">
                        All Applications
                      </option>
                      <option
                        v-for="job in allJobs"
                        :key="job.id"
                        :value="job.id"
                      >
                        {{ job.title }}
                      </option>
                    </select>
                  </div>
                </div>
                <div class="form-group form-full">
                  <label>Message</label>
                  <textarea
                    v-model="noticeForm.message"
                    class="form-textarea"
                    rows="3"
                    placeholder="Application results will be out on XX.XX.XXXX. Please be patient."
                    required
                  />
                </div>
                <div class="form-grid">
                  <div class="form-group">
                    <label>Start Date (optional)</label>
                    <input
                      v-model="noticeForm.startDate"
                      type="date"
                      class="form-input"
                    >
                  </div>
                  <div class="form-group">
                    <label>End Date (optional)</label>
                    <input
                      v-model="noticeForm.endDate"
                      type="date"
                      class="form-input"
                    >
                  </div>
                </div>
                <div style="display:flex; align-items:center; gap:12px; margin-top:8px;">
                  <button
                    type="submit"
                    class="btn btn-primary"
                    :disabled="postingNotice"
                  >
                    {{ postingNotice ? 'Posting...' : '📣 Post Notice' }}
                  </button>
                  <span
                    v-if="noticePosted"
                    style="color:#10b981; font-weight:700; font-size:0.85rem;"
                  >✔ Notice posted!</span>
                </div>
              </form>
            </div>

            <div
              v-if="loadingNotices && allNotices.length === 0"
              class="loading-state"
              style="margin-top:30px;"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingNotices }]"
              style="margin-top:30px;"
            >
              <table class="data-table">
                <thead><tr><th>Title</th><th>Message</th><th>Target</th><th>Author</th><th>Status</th><th>Dates</th><th>Actions</th></tr></thead>
                <tbody>
                  <tr
                    v-for="notice in allNotices"
                    :key="notice.id"
                  >
                    <td class="td-title">
                      {{ notice.title }}
                    </td>
                    <td style="max-width:280px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                      {{ notice.message }}
                    </td>
                    <td>
                      <span
                        v-if="notice.target === 'all'"
                        class="dept-tag"
                      >All</span>
                      <span
                        v-else
                        class="dept-tag"
                      >{{ getJobTitle(notice.target_job_id) }}</span>
                    </td>
                    <td><span class="author-tag">{{ notice.author_name || 'System' }}</span></td>
                    <td>
                      <span :class="['active-badge', { inactive: !notice.is_active }]">
                        {{ notice.is_active ? 'Active' : 'Inactive' }}
                      </span>
                    </td>
                    <td>
                      <span
                        v-if="notice.start_date || notice.end_date"
                        style="font-size:0.75rem; color:var(--muted);"
                      >
                        {{ notice.start_date || '—' }} → {{ notice.end_date || '—' }}
                      </span>
                      <span
                        v-else
                        style="font-size:0.75rem; color:var(--subtle);"
                      >No date range</span>
                    </td>
                    <td class="td-actions">
                      <button
                        class="action-btn action-toggle"
                        title="Toggle"
                        @click="toggleNotice(notice)"
                      >
                        <EyeSlashIcon
                          v-if="notice.is_active"
                          class="action-icon"
                          aria-hidden="true"
                        />
                        <EyeIcon
                          v-else
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                      <button
                        class="action-btn action-delete"
                        title="Delete"
                        @click="deleteNotice(notice.id)"
                      >
                        <TrashIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ BLACKLISTS TAB ═══ -->
          <div
            v-if="activeTab === 'blacklists'"
            class="tab-content"
          >
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">
                  Banned Users
                </h2>
                <p class="section-sub">
                  Manage users who are blacklisted from applying.
                </p>
              </div>
              <div
                class="toolbar"
                style="gap:10px;"
              >
                <input
                  v-model="newBanId"
                  class="form-input"
                  placeholder="Discord ID or Profile UUID"
                  style="width:250px"
                >
                <button
                  class="btn btn-danger btn-sm"
                  :disabled="!newBanId || savingItem"
                  @click="banUser"
                >
                  Ban User
                </button>
              </div>
            </div>
            <div
              v-if="loadingBans && allBans.length === 0"
              class="loading-state"
            >
              <div class="spinner" />
            </div>
            <div
              v-else
              :class="['table-wrap', { 'is-loading': loadingBans }]"
            >
              <table class="data-table">
                <thead><tr><th>User ID</th><th>Reason</th><th>Date Banned</th><th>Action</th></tr></thead>
                <tbody>
                  <tr
                    v-for="ban in allBans"
                    :key="ban.id"
                  >
                    <td>
                      <span
                        class="dept-tag"
                        style="background:rgba(0,0,0,0.1);color:var(--text)"
                      >{{ ban.user_id }}</span>
                    </td>
                    <td>{{ ban.reason || 'No reason provided' }}</td>
                    <td>{{ formatDate(ban.created_at) }}</td>
                    <td class="td-actions">
                      <button
                        class="action-btn action-toggle"
                        title="Unban"
                        @click="unbanUser(ban.user_id)"
                      >
                        <ArrowUturnLeftIcon
                          class="action-icon"
                          aria-hidden="true"
                        />
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- ═══ ADVANCED TAB ═══ -->
          <div v-if="activeTab === 'advanced'" class="tab-content">
            <div class="header-with-actions">
              <div>
                <h2 class="section-title">Advanced Tools</h2>
                <p class="section-sub">Power-user tools: export data and manage templates.</p>
              </div>
              <div class="toolbar">
                <div style="display:flex; gap:10px; align-items:center;">
                  <select v-model="createTemplateJobId" class="form-input" style="min-width:220px;">
                    <option disabled value="">Select job to create template</option>
                    <option v-for="j in allJobs" :key="j.id" :value="j.id">{{ j.title }}</option>
                  </select>
                  <button class="btn btn-outline btn-sm" @click="createTemplateFromJob(createTemplateJobId)" :disabled="!createTemplateJobId"><PlusIcon class="btn-icon" /> Create Template</button>
                  <button class="btn btn-primary btn-sm" @click="exportJobsCSV"><ArrowDownTrayIcon class="btn-icon" /> Export Jobs CSV</button>
                </div>
              </div>
            </div>

            <div style="margin-top:20px;">
              <h3 class="section-title" style="font-size:1rem; margin-bottom:8px;">Job Templates</h3>
              <div v-if="jobTemplates.length === 0" class="empty-state" style="padding:20px;">No templates yet. Create one from an existing job.</div>
              <div v-else style="display:flex; flex-direction:column; gap:10px;">
                <div v-for="(t, idx) in jobTemplates" :key="t.id" style="display:flex; align-items:center; justify-content:space-between; padding:12px; border:1px solid var(--border); border-radius:8px; background:var(--bg-alt);">
                  <div>
                    <div style="font-weight:800;">{{ t.name }}</div>
                    <div style="font-size:0.85rem; color:var(--muted);">{{ t.created_at }}</div>
                  </div>
                  <div style="display:flex; gap:8px;">
                    <button class="btn btn-outline btn-sm" @click="applyTemplate(t)">Apply</button>
                    <button class="btn btn-danger btn-sm" @click="deleteTemplate(idx)">Delete</button>
                  </div>
                </div>
              </div>
            </div>
          </div>

        </template>
      </ClientOnly>
    </div>

  </main>
</template>

<script setup>
definePageMeta({ layout: 'admin' })
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import {
  BriefcaseIcon,
  ClipboardDocumentListIcon,
  PlusIcon,
  PencilIcon,
  TrashIcon,
  EyeIcon,
  EyeSlashIcon,
  ShieldExclamationIcon,
  DocumentTextIcon,
  DocumentMagnifyingGlassIcon,
  XMarkIcon,
  MegaphoneIcon,
  NoSymbolIcon,
  ArrowUturnLeftIcon,
  BellAlertIcon,
  UsersIcon,
  UserGroupIcon,
  InformationCircleIcon,
  Cog6ToothIcon,
  ArrowDownTrayIcon
} from '@heroicons/vue/24/outline'

const supabase = useSupabase()
const router = useRouter()
const { isAdmin, user, loading, fetchProfile, permissions } = useAuth()
const refreshing = ref(false)
const maskAsStaff = ref(true)

const activeTab = ref('jobs')
const allJobs = ref([])
const loadingJobs = ref(true)

// Advanced tools: local templates + CSV export
const jobTemplates = ref([])
const createTemplateJobId = ref('')

function loadTemplates() {
  try {
    const raw = localStorage.getItem('adminJobTemplates')
    jobTemplates.value = raw ? JSON.parse(raw) : []
  } catch (e) {
    jobTemplates.value = []
  }
}

function saveTemplates() {
  try { localStorage.setItem('adminJobTemplates', JSON.stringify(jobTemplates.value)) } catch (e) { /* ignore */ }
}

function createTemplateFromJob(jobId) {
  if (!jobId) return
  const job = allJobs.value.find(j => j.id === jobId)
  if (!job) { alert('Job not found'); return }
  jobTemplates.value.push({ id: Date.now(), name: `${job.title} template`, data: { ...job }, created_at: new Date().toLocaleString() })
  createTemplateJobId.value = ''
  saveTemplates()
  showSaved()
}

function applyTemplate(t) {
  if (!t) return
  try { sessionStorage.setItem('jobTemplate', JSON.stringify(t.data)) } catch (e) {}
  router.push('/admin/jobs/create')
}

function deleteTemplate(idx) {
  if (!confirm('Delete template?')) return
  jobTemplates.value.splice(idx, 1)
  saveTemplates()
  showSaved()
}

function exportJobsCSV() {
  const fields = ['id','title','department','experience_level','location','salary','is_active','created_at']
  const rows = [fields.join(',')]
  allJobs.value.forEach(job => {
    const row = fields.map(f => {
      let v = job[f]
      if (v === null || v === undefined) return ''
      if (Array.isArray(v)) v = v.join('; ')
      v = String(v).replace(/"/g, '""')
      if (v.includes(',') || v.includes('"') || v.includes('\n')) v = `"${v}"`
      return v
    }).join(',')
    rows.push(row)
  })
  const blob = new Blob([rows.join('\n')], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = `jobs-export-${new Date().toISOString().slice(0,10)}.csv`
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}


const allApplications = ref([])
const loadingApps = ref(true)
const appFilter = ref('all')

const allBans = ref([])
const loadingBans = ref(true)
const newBanId = ref('')

const allAnnouncements = ref([])
const loadingAnnouncements = ref(true)
const newAnnouncement = ref({ title: '', content: '' })

// Notifications
const notifForm = ref({ title: '', message: '', type: 'info', target: 'all', targetId: '', link: '' })
const sendingNotif = ref(false)
const notifSent = ref(false)
const notifError = ref('')
const sentNotifications = ref([])
const loadingSentNotifs = ref(true)

// Staff
const allStaff = ref([])
const loadingStaff = ref(true)
const staffForm = ref({ userId: '', role: 'admin' })
const addingStaff = ref(false)
const staffAdded = ref(false)
const staffError = ref('')

// Accounts
const allAccounts = ref([])
const loadingAccounts = ref(true)
const accountsSearch = ref('')
const filteredAccounts = computed(() => {
  if (!accountsSearch.value) return allAccounts.value
  const query = accountsSearch.value.toLowerCase()
  return allAccounts.value.filter(a =>
    (a.discord_username && a.discord_username.toLowerCase().includes(query))
    || (a.discord_id && a.discord_id.includes(query))
  )
})

// Application Notices
const allNotices = ref([])
const loadingNotices = ref(true)
const noticeForm = ref({ title: '', message: '', target: 'all', startDate: '', endDate: '' })
const postingNotice = ref(false)
const noticePosted = ref(false)

const savingItem = ref(false)
const savedItem = ref(false)
let saveTimeout = null

function showSaved() {
  savingItem.value = false
  savedItem.value = true
  if (saveTimeout) clearTimeout(saveTimeout)
  saveTimeout = setTimeout(() => savedItem.value = false, 2500)
}

const filteredApplications = computed(() => {
  if (appFilter.value === 'all') return allApplications.value
  return allApplications.value.filter(a => a.status === appFilter.value)
})

function formatDate(date) {
  return new Date(date).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' })
}

// ── Fetch data ──────────────────────────
async function fetchAllJobs() {
  loadingJobs.value = true
  try {
    const { data } = await supabase.from('jobs').select('*').order('created_at', { ascending: false })
    if (data) allJobs.value = data
  } finally {
    loadingJobs.value = false
  }
}

async function fetchAllApplications() {
  loadingApps.value = true
  try {
    const { data } = await supabase
      .from('applications')
      .select('*, jobs(title, department)')
      .order('created_at', { ascending: false })
    if (data) allApplications.value = data
  } finally {
    loadingApps.value = false
  }
}

async function fetchBans() {
  loadingBans.value = true
  try {
    const { data } = await supabase.from('banned_users').select('*').order('created_at', { ascending: false })
    if (data) allBans.value = data
  } finally {
    loadingBans.value = false
  }
}

async function fetchAnnouncements() {
  loadingAnnouncements.value = true
  try {
    const { data } = await supabase.from('announcements').select('*').order('created_at', { ascending: false })
    if (data) allAnnouncements.value = data
  } finally {
    loadingAnnouncements.value = false
  }
}

async function fetchSentNotifications() {
  loadingSentNotifs.value = true
  try {
    const { data } = await supabase
      .from('notifications')
      .select('*')
      .or('category.eq.admin_broadcast,sent_by_name.not.is.null')
      .order('created_at', { ascending: false })
      .limit(50)
    if (data) sentNotifications.value = data
  } finally {
    loadingSentNotifs.value = false
  }
}

async function fetchStaff() {
  loadingStaff.value = true
  try {
    const { data } = await supabase
      .from('profiles')
      .select('*')
      .or('role.eq.admin,staff_role.not.is.null')
      .order('created_at', { ascending: false })
    if (data) allStaff.value = data
  } finally {
    loadingStaff.value = false
  }
}

async function fetchNotices() {
  loadingNotices.value = true
  try {
    const { data } = await supabase
      .from('application_notices')
      .select('*')
      .order('created_at', { ascending: false })
    if (data) allNotices.value = data
  } finally {
    loadingNotices.value = false
  }
}

// ── Job CRUD ────────────────────────────
async function fetchAllAccounts() {
  loadingAccounts.value = true
  try {
    const { data: profiles } = await supabase.from('profiles').select('*').order('created_at', { ascending: false })
    const { data: bans } = await supabase.from('banned_users').select('user_id')
    const bannedIds = new Set((bans || []).map(b => b.user_id))
    if (profiles) {
      allAccounts.value = profiles.map(p => ({
        ...p,
        is_banned: bannedIds.has(p.id)
      }))
    }
  } finally {
    loadingAccounts.value = false
  }
}

async function banSpecificUser(uid, username) {
  if (!confirm(`Are you sure you want to ban ${username}?`)) return
  savingItem.value = true
  try {
    await supabase.from('banned_users').insert({ user_id: uid, reason: 'Banned by admin panel', admin_id: user.value.id })
    await supabase.from('profiles').update({ role: 'user', staff_role: null }).eq('id', uid)
    await fetchAllAccounts()
    await fetchBans()
    showSaved()
  } finally { savingItem.value = false }
}

async function unbanSpecificUser(uid) {
  savingItem.value = true
  try {
    await supabase.from('banned_users').delete().eq('user_id', uid)
    await fetchAllAccounts()
    await fetchBans()
    showSaved()
  } finally { savingItem.value = false }
}



async function toggleJobActive(job) {
  savingItem.value = true
  try {
    await supabase.from('jobs').update({ is_active: !job.is_active }).eq('id', job.id)
    await fetchAllJobs()
    showSaved()
  } finally { savingItem.value = false }
}

async function deleteJob(job) {
  if (!confirm(`Delete "${job.title}"? This will also delete all related applications.`)) return
  savingItem.value = true
  try {
    await supabase.from('jobs').delete().eq('id', job.id)
    await fetchAllJobs()
    showSaved()
  } finally { savingItem.value = false }
}

// ── Applications ────────────────────────
async function updateApplicationStatus(app, newStatus) {
  savingItem.value = true
  try {
    const { data, error } = await supabase.from('applications').update({ status: newStatus, updated_at: new Date().toISOString() }).eq('id', app.id).select()

    if (error) {
      alert(`Status update failed: ${error.message}`)
      return
    }

    if (!data || data.length === 0) {
      alert('Status update rejected by Database Security Rules! (Ensure you have an Admin Role explicitly defined in Postgres).')
      return
    }

    app.status = newStatus

    // Add explicitly to history log so both applicant and admin see it
    await supabase.from('application_events').insert({
      application_id: app.id,
      event_type: 'status_change',
      description: `Status changed to ${newStatus}`,
      author_name: maskAsStaff.value ? 'Staff' : adminDisplayName.value,
      actual_author: adminDisplayName.value
    })

    // Dispatch cross-account notification directly to the applicant
    const jobTitle = app.jobs?.title || 'a job'
    await supabase.from('notifications').insert({
      user_id: app.user_id,
      title: 'Application Update',
      message: `Your application for ${jobTitle} has been marked as ${newStatus}.`,
      type: 'status_update',
      category: 'status_update',
      sent_by_name: maskAsStaff.value ? 'Staff' : adminDisplayName.value,
      actual_author: adminDisplayName.value,
      link: `/applications/${app.id}`
    })
    showSaved()
  } finally {
    savingItem.value = false
  }
}

async function rateApplication(app, rating) {
  savingItem.value = true
  try {
    await supabase.from('applications').update({ rating, updated_at: new Date().toISOString() }).eq('id', app.id)
    app.rating = rating
    showSaved()
  } finally {
    savingItem.value = false
  }
}

async function updateAdminNotes(app, notes) {
  savingItem.value = true
  try {
    await supabase.from('applications').update({ admin_notes: notes, updated_at: new Date().toISOString() }).eq('id', app.id)
    app.admin_notes = notes
    showSaved()
  } finally {
    savingItem.value = false
  }
}

// ── Blacklists & Announcements ───────────
async function banUser() {
  if (!newBanId.value.trim()) return
  savingItem.value = true
  try {
    let uid = newBanId.value.trim()
    if (!uid.includes('-')) {
      const { data } = await supabase.from('profiles').select('id').eq('discord_id', uid).maybeSingle()
      if (data) uid = data.id
      else { alert('User not found with that Discord ID'); return }
    }
    const { error } = await supabase.from('banned_users').insert({ user_id: uid, reason: 'Banned by admin', admin_id: user.value.id })
    if (error) alert(error.message)
    newBanId.value = ''
    await fetchBans()
    showSaved()
  } finally { savingItem.value = false }
}

async function unbanUser(userId) {
  savingItem.value = true
  try {
    await supabase.from('banned_users').delete().eq('user_id', userId)
    await fetchBans()
    showSaved()
  } finally { savingItem.value = false }
}

async function postAnnouncement() {
  savingItem.value = true
  try {
    const finalAuthor = maskAsStaff.value ? 'Staff' : adminDisplayName.value
    await supabase.from('announcements').insert({ title: newAnnouncement.value.title, content: newAnnouncement.value.content, created_by: user.value.id, author_name: finalAuthor })
    newAnnouncement.value = { title: '', content: '' }
    await fetchAnnouncements()
    showSaved()
  } finally { savingItem.value = false }
}
async function toggleAnnouncement(ann) {
  savingItem.value = true
  try {
    await supabase.from('announcements').update({ is_active: !ann.is_active }).eq('id', ann.id)
    await fetchAnnouncements()
    showSaved()
  } finally { savingItem.value = false }
}
async function deleteAnnouncement(id) {
  savingItem.value = true
  try {
    await supabase.from('announcements').delete().eq('id', id)
    await fetchAnnouncements()
    showSaved()
  } finally { savingItem.value = false }
}

// ── Notifications (Send) ─────────────────
const adminDisplayName = computed(() => user.value?.user_metadata?.full_name || user.value?.user_metadata?.name || 'Admin')

async function sendNotification() {
  sendingNotif.value = true
  notifSent.value = false
  notifError.value = ''

  try {
    let targetUserIds = []

    if (notifForm.value.target === 'all') {
      const { data } = await supabase.from('profiles').select('id')
      if (data) targetUserIds = data.map(p => p.id)
    } else if (notifForm.value.target === 'specific') {
      let uid = notifForm.value.targetId?.trim()
      if (!uid) { notifError.value = 'Please enter a Discord ID or UUID'; sendingNotif.value = false; return }
      if (!uid.includes('-')) {
        const { data } = await supabase.from('profiles').select('id').eq('discord_id', uid).maybeSingle()
        if (data) uid = data.id
        else { notifError.value = 'User not found with that Discord ID'; sendingNotif.value = false; return }
      }
      targetUserIds = [uid]
    } else if (notifForm.value.target.startsWith('status_')) {
      const status = notifForm.value.target.replace('status_', '')
      const { data } = await supabase.from('applications').select('user_id').eq('status', status)
      if (data) {
        const unique = [...new Set(data.map(a => a.user_id))]
        targetUserIds = unique
      }
    }

    if (targetUserIds.length === 0) {
      notifError.value = 'No users matched the target criteria'
      sendingNotif.value = false
      return
    }

    const notifications = targetUserIds.map(uid => ({
      user_id: uid,
      title: notifForm.value.title,
      message: notifForm.value.message,
      type: notifForm.value.type,
      category: 'admin_broadcast',
      sent_by_name: adminDisplayName.value,
      link: notifForm.value.link || null
    }))

    const { error } = await supabase.from('notifications').insert(notifications)
    if (error) throw error

    notifSent.value = true
    notifForm.value = { title: '', message: '', type: 'info', target: 'all', targetId: '', link: '' }
    await fetchSentNotifications()
    setTimeout(() => notifSent.value = false, 3000)
  } catch (err) {
    notifError.value = err.message || 'Failed to send notification'
  }
  sendingNotif.value = false
}

// ── Staff Management ─────────────────────
async function addStaff() {
  addingStaff.value = true
  staffAdded.value = false
  staffError.value = ''

  try {
    let uid = staffForm.value.userId?.trim()
    if (!uid) { staffError.value = 'Enter a Discord ID or UUID'; return }

    if (!uid.includes('-')) {
      const { data } = await supabase.from('profiles').select('id').eq('discord_id', uid).maybeSingle()
      if (data) uid = data.id
      else { staffError.value = 'No user found with that Discord ID'; return }
    }

    const { error } = await supabase.from('profiles').update({
      role: 'admin',
      staff_role: staffForm.value.role
    }).eq('id', uid)

    if (error) {
      throw error
    } else {
      staffAdded.value = true
      staffForm.value = { userId: '', role: 'admin' }
      await fetchStaff()
      setTimeout(() => staffAdded.value = false, 3000)
    }
  } catch (error) {
    staffError.value = error.message
  } finally {
    addingStaff.value = false
  }
}

async function changeStaffRole(s, newRole) {
  if (newRole === 'banned') {
    if (!confirm(`Are you sure you want to ban and demote ${s.discord_username}?`)) {
      await fetchStaff() // refresh ui
      return
    }
    savingItem.value = true
    try {
      await supabase.from('profiles').update({ role: 'user', staff_role: null, can_manage_jobs: false, can_manage_staff: false, can_manage_notices: false, can_post_announcements: false, can_send_notifications: false, can_ban_users: false }).eq('id', s.id)
      await supabase.from('banned_users').insert({ user_id: s.id, reason: 'Banned from staff panel', admin_id: user.value.id })
      await fetchStaff()
      await fetchBans()
      if (allAccounts.value.length > 0) fetchAllAccounts()
      showSaved()
    } finally { savingItem.value = false }
    return
  }

  savingItem.value = true
  try {
    await supabase.from('profiles').update({ staff_role: newRole }).eq('id', s.id)
    await fetchStaff()
    showSaved()
  } finally { savingItem.value = false }
}

async function updateStaffPermission(s, permission, value) {
  savingItem.value = true
  try {
    const { error } = await supabase.from('profiles').update({ [permission]: value }).eq('id', s.id)
    if (error) throw error
    s[permission] = value
    showSaved()
  } catch (err) {
    alert(`Failed to update permission: ${err.message}`)
  } finally {
    savingItem.value = false
  }
}

async function removeStaff(s) {
  if (s.discord_username === 'derkloking') return // Double safety
  if (!confirm(`Remove ${s.discord_username || 'this user'} from staff?`)) return
  savingItem.value = true
  try {
    await supabase.from('profiles').update({ role: 'user', staff_role: null, can_manage_jobs: false, can_manage_staff: false, can_manage_notices: false, can_post_announcements: false, can_send_notifications: false, can_ban_users: false }).eq('id', s.id)
    await fetchStaff()
    showSaved()
  } finally { savingItem.value = false }
}

// ── Application Notices ──────────────────
async function postNotice() {
  postingNotice.value = true
  noticePosted.value = false

  try {
    const isJobTarget = noticeForm.value.target !== 'all'
    const { error } = await supabase.from('application_notices').insert({
      title: noticeForm.value.title,
      message: noticeForm.value.message,
      target: isJobTarget ? 'job' : 'all',
      target_job_id: isJobTarget ? noticeForm.value.target : null,
      author_id: user.value.id,
      author_name: maskAsStaff.value ? 'Staff' : adminDisplayName.value,
      actual_author: adminDisplayName.value,
      start_date: noticeForm.value.startDate || null,
      end_date: noticeForm.value.endDate || null
    })

    if (!error) {
      noticePosted.value = true
      noticeForm.value = { title: '', message: '', target: 'all', startDate: '', endDate: '' }
      await fetchNotices()
      setTimeout(() => noticePosted.value = false, 3000)
    }
  } catch (error) {
    alert(`Failed to post notice: ${error.message}`)
  } finally {
    postingNotice.value = false
  }
}

async function toggleNotice(notice) {
  savingItem.value = true
  try {
    await supabase.from('application_notices').update({ is_active: !notice.is_active }).eq('id', notice.id)
    await fetchNotices()
    showSaved()
  } finally { savingItem.value = false }
}

async function deleteNotice(id) {
  savingItem.value = true
  try {
    await supabase.from('application_notices').delete().eq('id', id)
    await fetchNotices()
    showSaved()
  } finally { savingItem.value = false }
}

function getJobTitle(jobId) {
  const job = allJobs.value.find(j => j.id === jobId)
  return job ? job.title : 'Unknown Job'
}

function loadTab(tabName) {
  if (tabName === 'jobs') fetchAllJobs()
  else if (tabName === 'applications') fetchAllApplications()
  else if (tabName === 'announcements') fetchAnnouncements()
  else if (tabName === 'notifications') fetchSentNotifications()
  else if (tabName === 'staff') fetchStaff()
  else if (tabName === 'notices') fetchNotices()
  else if (tabName === 'blacklists') fetchBans()
}

watch(activeTab, loadTab)

// Only keep functions needed for dashboard actions
onMounted(async () => {
  if (isAdmin.value) {
    loadTab(activeTab.value)
    loadTemplates()
  }
})

// Watch for admin state to load after auth initializes
watch(isAdmin, async (val) => {
  if (val) {
    loadTab(activeTab.value)
    loadTemplates()
  }
})

useSeoMeta({ title: 'Admin Panel — Sunshine Studio' })
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; }
.container { max-width: 1100px; margin: 0 auto; padding: 0 24px; }

.page-header { padding: 48px 0 24px; }
.page-title {
  font-size: 1.5rem;
  font-weight: 900;
  color: var(--text);
  margin: 0 0 6px;
  letter-spacing: -0.02em;
}
.page-sub { font-size: 0.9rem; color: var(--muted); margin: 0; }

/* Tabs */
.tabs {
  display: flex;
  gap: 2px;
  border-bottom: 1px solid var(--border);
  margin-bottom: 24px;
}
.tab {
  display: flex;
  align-items: center;
  gap: 6px;
  padding: 10px 16px;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--muted);
  background: transparent;
  border: none;
  cursor: pointer;
  border-bottom: 2px solid transparent;
  transition: color 150ms ease, border-color 150ms ease;
  margin-bottom: -1px;
}
.tab:hover { color: var(--text); }
.tab.active {
  color: var(--red);
  border-bottom-color: var(--red);
}
.tab-icon { width: 16px; height: 16px; }

/* Toolbar */
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 20px;
  flex-wrap: wrap;
  gap: 12px;
}

/* Buttons */
.btn {
  display: inline-flex;
  align-items: center;
  gap: 7px;
  font-size: 0.875rem;
  font-weight: 600;
  padding: 10px 20px;
  border-radius: 7px;
  text-decoration: none;
  border: none;
  cursor: pointer;
  transition: background 150ms ease, transform 130ms ease;
  white-space: nowrap;
}
.btn-sm { padding: 8px 14px; font-size: 0.82rem; }
.btn-icon { width: 15px; height: 15px; }
.btn-primary { background: var(--red); color: #fff; }
.btn-primary:hover { background: var(--red-hover); }
.btn-primary:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-outline { background: transparent; color: var(--muted); border: 1px solid var(--border); }
.btn-outline:hover { color: var(--text); border-color: var(--muted); }
.btn-outline:disabled { opacity: 0.5; cursor: not-allowed; }
.btn-danger { background: #ef4444; color: #fff; }
.btn-danger:hover { background: #dc2626; }
.btn-danger:disabled { opacity: 0.5; cursor: not-allowed; }

/* Filter tags */
.filter-tags { display: flex; gap: 6px; flex-wrap: wrap; }
.filter-tag {
  font-size: 0.75rem;
  font-weight: 600;
  padding: 5px 12px;
  border-radius: 99px;
  border: 1px solid var(--border);
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  text-transform: capitalize;
  transition: all 150ms ease;
}
.filter-tag:hover { border-color: var(--red); color: var(--red); }
.filter-tag.active { background: rgba(232,55,42,0.1); border-color: var(--red); color: var(--red); }

/* Data table */
.table-wrap {
  overflow-x: auto;
  border: 1px solid var(--border);
  border-radius: 10px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.84rem;
}
.data-table th {
  text-align: left;
  padding: 12px 16px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.04em;
  color: var(--subtle);
  border-bottom: 1px solid var(--border);
  background: var(--bg-alt, var(--bg));
}
.data-table td {
  padding: 12px 16px;
  color: var(--text);
  border-bottom: 1px solid var(--border);
  vertical-align: middle;
}
.data-table tr:last-child td { border-bottom: none; }
.data-table tr:hover td { background: rgba(232,55,42,0.02); }

.td-title { font-weight: 600; }
.td-actions { display: flex; gap: 4px; }

.dept-tag {
  font-size: 0.68rem;
  font-weight: 700;
  letter-spacing: 0.06em;
  text-transform: uppercase;
  color: var(--red);
  background: rgba(232,55,42,0.09);
  padding: 2px 8px;
  border-radius: 99px;
  align-self: flex-start;
  white-space: nowrap;
}

.active-badge {
  font-size: 0.72rem;
  font-weight: 600;
  padding: 2px 8px;
  border-radius: 99px;
  background: rgba(34,197,94,0.1);
  color: #22c55e;
}
.active-badge.inactive {
  background: rgba(107,114,128,0.1);
  color: #6b7280;
}

.action-btn {
  padding: 6px;
  border: none;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  border-radius: 5px;
  display: inline-flex;
  transition: color 150ms ease, background 150ms ease;
}
.action-btn:hover { color: var(--text); background: var(--bg-alt, rgba(0,0,0,0.04)); }
.action-delete:hover { color: #ef4444; background: rgba(239,68,68,0.08); }
.action-icon { width: 16px; height: 16px; }

/* Applicant cell */
.applicant-cell { display: flex; align-items: center; gap: 8px; }
.applicant-avatar {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid var(--border);
}
.avatar-placeholder {
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: rgba(232,55,42,0.1);
  color: var(--red);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 0.75rem;
  font-weight: 700;
}
.applicant-name { font-weight: 500; }

.status-select {
  font-size: 0.8rem;
  padding: 4px 8px;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: var(--surface);
  color: var(--text);
  cursor: pointer;
  outline: none;
}
.status-select:focus { border-color: var(--red); }

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0,0,0,0.5);
  backdrop-filter: blur(4px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 100;
  padding: 20px;
}
.modal {
  background: var(--surface, #fff);
  border: 1px solid var(--border);
  border-radius: 16px;
  width: 100%;
  max-width: 640px;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 16px 48px rgba(0,0,0,0.15);
}
.modal-sm { max-width: 480px; }

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 20px 24px;
  border-bottom: 1px solid var(--border);
}
.modal-title { font-size: 1.1rem; font-weight: 800; color: var(--text); margin: 0; }
.modal-close {
  border: none;
  background: transparent;
  color: var(--muted);
  cursor: pointer;
  padding: 4px;
  border-radius: 6px;
  display: flex;
  transition: color 150ms ease;
}
.modal-close:hover { color: var(--text); }
.modal-close-icon { width: 20px; height: 20px; }

.modal-body { padding: 24px; }
.modal-footer {
  padding: 16px 24px;
  border-top: 1px solid var(--border);
  display: flex;
  justify-content: flex-end;
  gap: 8px;
}

/* Form */
.form-grid {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 14px;
  margin-bottom: 14px;
}
.form-group { display: flex; flex-direction: column; gap: 4px; }
.form-full { margin-bottom: 14px; }
.form-group label {
  font-size: 0.76rem;
  font-weight: 600;
  color: var(--muted);
  text-transform: uppercase;
  letter-spacing: 0.03em;
}
.form-input, .form-textarea {
  padding: 9px 12px;
  border: 1px solid var(--border);
  border-radius: 7px;
  background: var(--bg);
  color: var(--text);
  font-size: 0.85rem;
  outline: none;
  font-family: inherit;
  transition: border-color 150ms ease;
}
.form-input:focus, .form-textarea:focus { border-color: var(--red); }
.form-textarea { resize: vertical; }

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.85rem !important;
  text-transform: none !important;
  color: var(--text) !important;
  cursor: pointer;
}

.error-text { color: #ef4444; font-size: 0.8rem; text-align: center; padding: 0 24px 16px; }

/* Cover letter modal */
.cover-applicant { font-size: 0.85rem; color: var(--muted); margin: 0 0 12px; }
.cover-text { font-size: 0.9rem; color: var(--text); line-height: 1.7; margin: 0; white-space: pre-wrap; }

/* Modal animation */
.modal-fade-enter-active { transition: opacity 200ms ease; }
.modal-fade-enter-active .modal { transition: transform 200ms ease; }
.modal-fade-leave-active { transition: opacity 150ms ease; }
.modal-fade-leave-active .modal { transition: transform 150ms ease; }
.modal-fade-enter-from { opacity: 0; }
.modal-fade-enter-from .modal { transform: scale(0.95) translateY(10px); }
.modal-fade-leave-to { opacity: 0; }
.modal-fade-leave-to .modal { transform: scale(0.95) translateY(10px); }

/* Loading & empty */
.loading-state, .empty-state { text-align: center; padding: 60px 20px; color: var(--muted); }
.spinner {
  width: 32px; height: 32px;
  border: 3px solid var(--border);
  border-top-color: var(--red);
  border-radius: 50%;
  animation: spin 0.7s linear infinite;
  margin: 0 auto 16px;
}
@keyframes spin { to { transform: rotate(360deg); } }
.empty-icon { width: 48px; height: 48px; color: var(--subtle); margin-bottom: 12px; }

@media (max-width: 640px) {
  .form-grid { grid-template-columns: 1fr; }
}

/* Rating stars */
.rating-stars { display: flex; gap: 2px; }
.rating-stars-lg { gap: 4px; }
.star-btn {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1rem;
  color: var(--border);
  transition: color 120ms ease, transform 120ms ease;
  padding: 0;
  line-height: 1;
}
.rating-stars-lg .star-btn { font-size: 1.4rem; }
.star-btn:hover { transform: scale(1.2); }
.star-btn.filled { color: #f59e0b; }

/* Application detail modal */
.detail-applicant {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 20px;
  padding-bottom: 16px;
  border-bottom: 1px solid var(--border);
}
.detail-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  object-fit: cover;
  border: 1px solid var(--border);
}
.detail-meta {
  font-size: 0.78rem;
  color: var(--muted);
  margin-top: 2px;
}

.detail-section {
  margin-bottom: 20px;
}
.detail-section-title {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--muted);
  margin: 0 0 8px;
}

.admin-notes-textarea {
  width: 100%;
  padding: 9px 12px;
  border: 1px solid var(--border);
  border-radius: 7px;
  background: var(--bg);
  color: var(--text);
  font-size: 0.85rem;
  font-family: inherit;
  outline: none;
  resize: vertical;
  transition: border-color 150ms ease;
}
.admin-notes-textarea:focus { border-color: var(--red); }

.answers-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}
.answer-item {
  background: var(--bg);
  border: 1px solid var(--border);
  border-radius: 8px;
  padding: 12px 14px;
}
.answer-question {
  font-size: 0.78rem;
  font-weight: 600;
  color: var(--muted);
  margin-bottom: 4px;
}
.answer-value {
  font-size: 0.88rem;
  color: var(--text);
  line-height: 1.5;
}
.tag-ai-flagged {
  font-size: 0.68rem;
  font-weight: 800;
  background: rgba(239, 68, 68, 0.1);
  color: #ef4444;
  padding: 3px 8px;
  border-radius: 99px;
  text-transform: uppercase;
}
.tag-ai-clear {
  font-size: 0.68rem;
  color: var(--muted);
  font-weight: 600;
}

/* Stats */
.admin-stats {
  display: flex;
  gap: 12px;
}
.stat-mini {
  background: var(--surface);
  border: 1px solid var(--border);
  padding: 8px 16px;
  border-radius: 8px;
  display: flex;
  flex-direction: column;
}
.stat-mini-label { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); font-weight: 700; }
.stat-mini-val { font-size: 1.1rem; font-weight: 800; color: var(--text); line-height: 1; margin-top: 4px; }
.text-red { color: #ef4444 !important; }

.header-with-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

/* Author tag */
.author-tag {
  font-size: 0.72rem;
  font-weight: 700;
  background: rgba(59,130,246,0.1);
  color: #3b82f6;
  padding: 2px 8px;
  border-radius: 99px;
  white-space: nowrap;
}

/* Compose card */
.compose-card {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 28px;
  border-left: 4px solid var(--red);
}
.compose-title {
  font-size: 1rem;
  font-weight: 800;
  color: var(--text);
  margin: 0 0 20px;
}
.compose-form .form-grid { margin-bottom: 14px; }
.compose-form .form-full { margin-bottom: 14px; }

/* Type badges */
.type-badge {
  font-size: 0.68rem;
  font-weight: 800;
  padding: 3px 8px;
  border-radius: 99px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.type-info { background: rgba(59,130,246,0.1); color: #3b82f6; }
.type-warning { background: rgba(245,158,11,0.12); color: #f59e0b; }
.type-urgent { background: rgba(239,68,68,0.1); color: #ef4444; }
.type-application_notice { background: rgba(139,92,246,0.1); color: #8b5cf6; }
.type-system { background: rgba(107,114,128,0.1); color: #6b7280; }
.type-admin_broadcast { background: rgba(59,130,246,0.1); color: #3b82f6; }
.type-status_update { background: rgba(34,197,94,0.1); color: #22c55e; }

/* Staff role badges */
.staff-role-badge {
  font-size: 0.7rem;
  font-weight: 800;
  padding: 3px 10px;
  border-radius: 99px;
  text-transform: uppercase;
  letter-spacing: 0.04em;
}
.role-owner { background: rgba(245,158,11,0.15); color: #f59e0b; }
.role-admin { background: rgba(239,68,68,0.1); color: #ef4444; }
.role-moderator { background: rgba(139,92,246,0.1); color: #8b5cf6; }
.role-staff { background: rgba(34,197,94,0.1); color: #22c55e; }
.role-user { background: rgba(107,114,128,0.1); color: #6b7280; }

.btn-danger { background: #ef4444; color: #fff; }
.btn-danger:hover { background: #dc2626; }
.btn-danger:disabled { opacity: 0.6; cursor: not-allowed; }
</style>
