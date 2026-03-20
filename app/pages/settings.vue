<template>
  <main class="page">
    <div class="settings-layout container">
      <div
        v-if="loading"
        class="loading-state"
      >
        <div class="spinner" />
        <p>Loading massive settings dashboard...</p>
      </div>

      <template v-else-if="user">
        <!-- Settings Sidebar -->
        <aside class="settings-sidebar">
          <div class="sidebar-user">
            <img
              :src="profile?.discord_avatar || 'https://cdn.discordapp.com/embed/avatars/0.png'"
              class="sidebar-avatar"
            >
            <div class="sidebar-user-info">
              <span class="user-fullname">{{ opts.displayName || user.user_metadata?.full_name || user.email?.split('@')[0] }}</span>
              <span class="user-role">{{ profile?.staff_role || profile?.role || 'User' }}</span>
              <span
                v-if="opts.statusMsg"
                class="user-status-msg"
              >{{ opts.statusMsg }}</span>
            </div>
          </div>
          <nav class="settings-nav">
            <button
              :class="['nav-item', { active: activeTab === 'profile' }]"
              @click="activeTab = 'profile'"
            >
              <UserIcon class="nav-icon" /> Public Profile
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'appearance' }]"
              @click="activeTab = 'appearance'"
            >
              <PaintBrushIcon class="nav-icon" /> Appearance
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'notifications' }]"
              @click="activeTab = 'notifications'"
            >
              <BellIcon class="nav-icon" /> Notifications
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'privacy' }]"
              @click="activeTab = 'privacy'"
            >
              <EyeIcon class="nav-icon" /> Privacy & Security
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'preferences' }]"
              @click="activeTab = 'preferences'"
            >
              <AdjustmentsHorizontalIcon class="nav-icon" /> Preferences
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'developer' }]"
              @click="activeTab = 'developer'"
            >
              <CodeBracketIcon class="nav-icon" /> Developer
            </button>
            <button
              :class="['nav-item', { active: activeTab === 'account' }]"
              @click="activeTab = 'account'"
            >
              <ShieldCheckIcon class="nav-icon" /> Danger Zone
            </button>
          </nav>

          <div class="sidebar-footer">
            <span>Jet2 OS v1.2</span>
            <span>Settings synced locally</span>
          </div>
        </aside>

        <!-- Settings Content -->
        <section class="settings-content">
          <div class="content-header">
            <div>
              <h1 class="page-title">
                {{ tabTitle }}
              </h1>
              <p class="page-sub">
                {{ tabDescription }}
              </p>
            </div>

            <div
              v-if="hasChanges"
              class="unsaved-badge"
            >
              <button
                class="btn btn-primary btn-sm"
                @click="saveAll"
              >
                Save Changes
              </button>
            </div>
          </div>

          <!-- ================= PROFILE ================= -->
          <div
            v-show="activeTab === 'profile'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Identity Base
            </div>
            <div class="setting-card">
              <div class="setting-grid-2">
                <div class="setting-form-group">
                  <label>Display Name</label>
                  <input
                    v-model="opts.displayName"
                    class="form-input"
                    placeholder="e.g. John Doe"
                  >
                </div>
                <div class="setting-form-group">
                  <label>Pronouns</label>
                  <input
                    v-model="opts.pronouns"
                    class="form-input"
                    placeholder="e.g. He/Him"
                  >
                </div>
                <div class="setting-form-group">
                  <label>Status Message</label>
                  <input
                    v-model="opts.statusMsg"
                    class="form-input"
                    placeholder="Set a custom status..."
                  >
                </div>
                <div class="setting-form-group">
                  <label>Current Location / Region</label>
                  <input
                    v-model="opts.location"
                    class="form-input"
                    placeholder="Germany, UK, USA..."
                  >
                </div>
              </div>
            </div>

            <div class="setting-group-title">
              Platform Connections
            </div>
            <div class="setting-card">
              <div class="setting-form-group">
                <label>Discord Connection</label>
                <div class="discord-connected-box">
                  <div style="display:flex; align-items:center; gap: 12px;">
                    <CheckCircleIcon
                      class="text-green"
                      style="width:20px;height:20px;color:#10b981"
                    />
                    <span style="font-weight:600; font-size: 0.9rem;">Connected as {{ profile?.discord_username || user.email }}</span>
                  </div>
                  <span style="font-size:0.75rem; color:var(--muted)">ID: {{ profile?.discord_id || 'Hidden' }}</span>
                </div>
              </div>

              <div
                class="setting-grid-2"
                style="margin-top:20px;"
              >
                <div class="setting-form-group">
                  <label>Roblox Username</label>
                  <input
                    v-model="opts.robloxUsername"
                    class="form-input"
                    placeholder="Your Roblox username..."
                  >
                </div>
                <div class="setting-form-group">
                  <label>Personal Website</label>
                  <input
                    v-model="opts.website"
                    class="form-input"
                    placeholder="https://..."
                  >
                </div>
              </div>
            </div>

            <div class="setting-group-title">
              Biography
            </div>
            <div class="setting-card">
              <div class="setting-form-group">
                <label>About Me</label>
                <textarea
                  v-model="opts.bio"
                  class="form-textarea"
                  rows="5"
                  placeholder="Write a highly-detailed professional summary..."
                />
              </div>
            </div>
          </div>

          <!-- ================= APPEARANCE ================= -->
          <div
            v-show="activeTab === 'appearance'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Visual Theme
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <MoonIcon class="setting-icon" /><div><span class="setting-name">Dark Mode Engine</span><span class="setting-desc">Switch between absolute darkness and light themes.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.theme === 'dark' }]"
                  @click="opts.theme = opts.theme === 'dark' ? 'light' : 'dark'; toggleTheme()"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <PaintBrushIcon class="setting-icon" /><div><span class="setting-name">Pure Black Mode</span><span class="setting-desc">For OLED screens. Only active when Dark Mode is on.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.pureBlack }]"
                  @click="opts.pureBlack = !opts.pureBlack"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <SwatchIcon class="setting-icon" /><div><span class="setting-name">Accent Color Override</span><span class="setting-desc">Change the primary red accent to a custom hex code.</span></div>
                </div>
                <div style="display:flex;align-items:center;gap:10px;">
                  <input
                    v-model="opts.accentColor"
                    type="color"
                    style="width:40px;height:40px;border:none;border-radius:8px;background:none;cursor:pointer;"
                  >
                  <button
                    class="btn btn-outline btn-sm"
                    @click="opts.accentColor = '#ef4444'"
                  >
                    Reset
                  </button>
                </div>
              </div>
            </div>

            <div class="setting-group-title">
              Accessibility & Zoom
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">UI Interface Scale</span><span class="setting-desc">Zoom the entire interface in or out. ({{ opts.zoom }}%)</span></div>
                </div>
                <input
                  v-model="opts.zoom"
                  type="range"
                  min="70"
                  max="150"
                  step="10"
                  style="width:150px;"
                >
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">High Contrast UI</span><span class="setting-desc">Enhances text readability against dark elements.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.highContrast }]"
                  @click="opts.highContrast = !opts.highContrast"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Dyslexic Font</span><span class="setting-desc">Change the system font to open-dyslexic.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.dyslexicFont }]"
                  @click="opts.dyslexicFont = !opts.dyslexicFont"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Animation Limits
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Reduce Motion</span><span class="setting-desc">Disable complex animations and UI transitions.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.reduceMotion }]"
                  @click="opts.reduceMotion = !opts.reduceMotion"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Disable Background Blurs</span><span class="setting-desc">Improves performance on lower end devices.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.disableBlurs }]"
                  @click="opts.disableBlurs = !opts.disableBlurs"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Layout & Density
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Compact Tables</span><span class="setting-desc">Remove padding in admin and user tables.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.compactMode }]"
                  @click="opts.compactMode = !opts.compactMode"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Hide Sidebar Automatically</span><span class="setting-desc">Collapse sidebar on page load.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.autoHideSidebar }]"
                  @click="opts.autoHideSidebar = !opts.autoHideSidebar"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>
          </div>

          <!-- ================= NOTIFICATIONS ================= -->
          <div
            v-show="activeTab === 'notifications'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Email Notifications
            </div>
            <div class="setting-card">
              <div
                v-for="(val, key) in emailNotifs"
                :key="key"
                class="setting-row"
              >
                <div class="setting-info">
                  <div><span class="setting-name">{{ val.name }}</span><span class="setting-desc">{{ val.desc }}</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts[key] }]"
                  @click="opts[key] = !opts[key]"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Push Notifications (Desktop)
            </div>
            <div class="setting-card">
              <div
                v-for="(val, key) in pushNotifs"
                :key="key"
                class="setting-row"
              >
                <div class="setting-info">
                  <div><span class="setting-name">{{ val.name }}</span><span class="setting-desc">{{ val.desc }}</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts[key] }]"
                  @click="opts[key] = !opts[key]"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              In-App Sounds & Volume
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Play Sound on Alert</span><span class="setting-desc">Play a 'ping' when a new alert displays.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.soundAlerts }]"
                  @click="opts.soundAlerts = !opts.soundAlerts"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Play Sound on Application Change</span><span class="setting-desc">Play a chime when app status updates.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.soundApp }]"
                  @click="opts.soundApp = !opts.soundApp"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Master Volume</span><span class="setting-desc">Overall volume for all sound effects ({{ opts.volume }}%).</span></div>
                </div>
                <input
                  v-model="opts.volume"
                  type="range"
                  min="0"
                  max="100"
                  style="width:150px;"
                >
              </div>
            </div>

            <div class="setting-group-title">
              Quiet Hours / Scheduling
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Enable Quiet Hours</span><span class="setting-desc">Mute all non-critical notifications on schedule.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.quietHours }]"
                  @click="opts.quietHours = !opts.quietHours"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div
                v-if="opts.quietHours"
                class="setting-grid-2"
                style="margin-top:10px; border-top: 1px solid var(--border); padding-top:20px;"
              >
                <div class="setting-form-group">
                  <label>Start Time</label>
                  <input
                    v-model="opts.quietStart"
                    type="time"
                    class="form-input"
                  >
                </div>
                <div class="setting-form-group">
                  <label>End Time</label>
                  <input
                    v-model="opts.quietEnd"
                    type="time"
                    class="form-input"
                  >
                </div>
              </div>
            </div>

            <div class="setting-group-title">
              External Integrations
            </div>
            <div class="setting-card">
              <div class="setting-form-group">
                <label>Custom Webhook URL</label>
                <input
                  v-model="opts.webhookUrl"
                  class="form-input"
                  placeholder="https://discord.com/api/webhooks/..."
                >
                <p
                  class="setting-desc"
                  style="margin-top:4px;"
                >
                  Dispatch all notification events to this webhook.
                </p>
              </div>
            </div>
          </div>

          <!-- ================= PRIVACY ================= -->
          <div
            v-show="activeTab === 'privacy'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Profile Visibility
            </div>
            <div class="setting-card">
              <div
                v-for="(val, key) in privacyToggles"
                :key="key"
                class="setting-row"
              >
                <div class="setting-info">
                  <div><span class="setting-name">{{ val.name }}</span><span class="setting-desc">{{ val.desc }}</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts[key] }]"
                  @click="opts[key] = !opts[key]"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Session Management
            </div>
            <div class="setting-card">
              <p
                class="setting-desc"
                style="margin-bottom:15px;"
              >
                You are currently signed in on this device. For security algorithms to take effect, ensure your sessions are managed properly.
              </p>
              <div
                class="setting-row"
                style="background:var(--bg); border: 1px solid var(--border); padding: 16px; border-radius: 8px;"
              >
                <div class="setting-info">
                  <GlobeAltIcon class="setting-icon text-green" /><div><span class="setting-name">Chrome on Linux (Current)</span><span class="setting-desc">Active right now • IP: HIDDEN</span></div>
                </div>
                <button
                  class="btn btn-primary btn-sm"
                  disabled
                >
                  Current
                </button>
              </div>
              <div style="margin-top:16px; display:flex; gap:10px;">
                <button class="btn btn-outline">
                  Revoke All Other Sessions
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Data Collection & Telemetry
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Send Crash Reports</span><span class="setting-desc">Send anonymous frontend stack traces if the app crashes.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.telemetryCrash }]"
                  @click="opts.telemetryCrash = !opts.telemetryCrash"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Share Anonymous Usage</span><span class="setting-desc">Help improve Jet2 Jobs by sharing usage behaviors.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.telemetryUsage }]"
                  @click="opts.telemetryUsage = !opts.telemetryUsage"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Strict Cookie Mode</span><span class="setting-desc">Reject all localstorage caches (Warning: May break caching).</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.strictCookies }]"
                  @click="opts.strictCookies = !opts.strictCookies"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Data Takeout
            </div>
            <div class="setting-card">
              <div
                class="setting-info"
                style="margin-bottom:12px;"
              >
                <div><span class="setting-name">Export My Data</span><span class="setting-desc">Download a JSON archive of all your applications and settings.</span></div>
              </div>
              <button
                class="btn btn-outline"
                @click="mockAction('Data Export Scheduled')"
              >
                Request JSON Archive
              </button>
            </div>
          </div>

          <!-- ================= PREFERENCES ================= -->
          <div
            v-show="activeTab === 'preferences'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Localization
            </div>
            <div class="setting-card">
              <div class="setting-grid-2">
                <div class="setting-form-group">
                  <label>Language</label>
                  <select
                    v-model="opts.language"
                    class="form-input"
                  >
                    <option value="en">
                      English (US)
                    </option>
                    <option value="en-gb">
                      English (UK)
                    </option>
                    <option value="de">
                      Deutsch
                    </option>
                    <option value="es">
                      Español
                    </option>
                    <option value="fr">
                      Français
                    </option>
                  </select>
                </div>
                <div class="setting-form-group">
                  <label>Timezone</label>
                  <select
                    v-model="opts.timezone"
                    class="form-input"
                  >
                    <option value="UTC">
                      UTC (Universal)
                    </option>
                    <option value="GMT">
                      GMT
                    </option>
                    <option value="EST">
                      EST
                    </option>
                    <option value="PST">
                      PST
                    </option>
                    <option value="CET">
                      CET
                    </option>
                  </select>
                </div>
                <div class="setting-form-group">
                  <label>Date Format</label>
                  <select
                    v-model="opts.dateFormat"
                    class="form-input"
                  >
                    <option value="MM/DD/YYYY">
                      MM/DD/YYYY
                    </option>
                    <option value="DD/MM/YYYY">
                      DD/MM/YYYY
                    </option>
                    <option value="YYYY-MM-DD">
                      YYYY-MM-DD
                    </option>
                  </select>
                </div>
                <div class="setting-form-group">
                  <label>First Day of Week</label>
                  <select
                    v-model="opts.weekStart"
                    class="form-input"
                  >
                    <option value="sun">
                      Sunday
                    </option>
                    <option value="mon">
                      Monday
                    </option>
                  </select>
                </div>
              </div>
            </div>

            <div class="setting-group-title">
              App Functionality
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Auto-save Drafts</span><span class="setting-desc">Automatically save application inputs every 30 seconds.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.autoSave }]"
                  @click="opts.autoSave = !opts.autoSave"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Autoplay Videos</span><span class="setting-desc">Autoplay tutorial videos on the dashboard.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.autoplay }]"
                  @click="opts.autoplay = !opts.autoplay"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Confirm Destructive Actions</span><span class="setting-desc">Show confirmation dialogs when deleting content.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.confirmDestructive }]"
                  @click="opts.confirmDestructive = !opts.confirmDestructive"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name">Hide Completed Jobs</span><span class="setting-desc">Hide jobs that have been closed aggressively.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.hideClosed }]"
                  @click="opts.hideClosed = !opts.hideClosed"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div class="setting-group-title">
              Navigation Default
            </div>
            <div class="setting-card">
              <div class="setting-form-group">
                <label>Default Admin Tab</label>
                <select
                  v-model="opts.defaultAdminTab"
                  class="form-input"
                >
                  <option value="applications">
                    Applications
                  </option>
                  <option value="jobs">
                    Jobs
                  </option>
                  <option value="staff">
                    Staff
                  </option>
                  <option value="accounts">
                    Accounts
                  </option>
                </select>
              </div>
            </div>
          </div>

          <!-- ================= DEVELOPER ================= -->
          <div
            v-show="activeTab === 'developer'"
            class="tab-pane"
          >
            <div class="setting-group-title">
              Developer Mode
            </div>
            <div class="setting-card">
              <div class="setting-row">
                <div class="setting-info">
                  <div><span class="setting-name text-red">Enable Developer Mode</span><span class="setting-desc">Turn on advanced API and networking tools. Do not use unless you know what you are doing.</span></div>
                </div>
                <button
                  :class="['toggle-switch', { active: opts.devMode }]"
                  style="border:1px solid #ef4444"
                  @click="opts.devMode = !opts.devMode"
                >
                  <span class="toggle-knob" />
                </button>
              </div>
            </div>

            <div
              v-if="opts.devMode"
              style="animation: fade 0.3s ease;"
            >
              <div class="setting-group-title">
                API Keys & Tokens
              </div>
              <div class="setting-card">
                <div class="setting-form-group">
                  <label>Personal Access Token (PAT)</label>
                  <div style="display:flex;gap:10px;">
                    <input
                      type="password"
                      class="form-input"
                      disabled
                      value="sk-live-asdf897as9df7a9sdf"
                      style="flex:1;"
                    >
                    <button
                      class="btn btn-outline"
                      @click="mockAction('Token Copied')"
                    >
                      Copy
                    </button>
                    <button
                      class="btn btn-outline text-red"
                      @click="mockAction('Token Revoked')"
                    >
                      Revoke
                    </button>
                  </div>
                  <p
                    class="setting-desc"
                    style="margin-top:4px;"
                  >
                    Used for programmatic access to the Jet2 Jobs GraphQL API.
                  </p>
                </div>
              </div>

              <div class="setting-group-title">
                Client Overrides
              </div>
              <div class="setting-card">
                <div
                  v-for="(val, key) in devOverrides"
                  :key="key"
                  class="setting-row"
                >
                  <div class="setting-info">
                    <div><span class="setting-name">{{ val.name }}</span><span class="setting-desc">{{ val.desc }}</span></div>
                  </div>
                  <button
                    :class="['toggle-switch', { active: opts[key] }]"
                    @click="opts[key] = !opts[key]"
                  >
                    <span class="toggle-knob" />
                  </button>
                </div>
              </div>

              <div class="setting-group-title">
                Console Logging Level
              </div>
              <div class="setting-card">
                <div class="setting-form-group">
                  <select
                    v-model="opts.logLevel"
                    class="form-input"
                  >
                    <option value="none">
                      None
                    </option>
                    <option value="error">
                      Error Only
                    </option>
                    <option value="warn">
                      Warnings + Errors
                    </option>
                    <option value="info">
                      Info
                    </option>
                    <option value="debug">
                      Debug (Extremely Verbose)
                    </option>
                  </select>
                </div>
              </div>
            </div>
          </div>

          <!-- ================= ACCOUNT / SECURITY ================= -->
          <div
            v-show="activeTab === 'account'"
            class="tab-pane"
          >
            <h3
              class="danger-title"
              style="color:#ef4444; font-size:1.1rem; text-transform:uppercase; font-weight:900; letter-spacing:0.05em; margin-bottom:20px;"
            >
              Safety Controls
            </h3>

            <div class="setting-card">
              <div
                class="setting-row"
                style="flex-direction: column; align-items: flex-start; gap: 10px;"
              >
                <div
                  class="setting-info"
                  style="width:100%;"
                >
                  <ArrowRightStartOnRectangleIcon class="setting-icon" />
                  <div>
                    <span class="setting-name">Sign Out</span>
                    <span class="setting-desc">End your current session safely on this device.</span>
                  </div>
                </div>
                <button
                  class="btn btn-outline"
                  style="align-self: flex-start; margin-top:10px;"
                  @click="handleSignOut"
                >
                  Sign Out
                </button>
              </div>
            </div>

            <div
              class="setting-card setting-card-danger"
              style="margin-top:40px;"
            >
              <div
                class="setting-row"
                style="flex-direction: column; align-items: flex-start; gap: 10px;"
              >
                <div
                  class="setting-info"
                  style="width:100%;"
                >
                  <TrashIcon
                    class="setting-icon"
                    style="color: #ef4444;"
                  />
                  <div>
                    <span
                      class="setting-name"
                      style="color: #ef4444;"
                    >Wipe Configuration Data</span>
                    <span class="setting-desc">Reset all 100+ settings applied on this page back to system defaults.</span>
                  </div>
                </div>
                <button
                  class="btn btn-danger"
                  style="align-self: flex-start; margin-top:10px;"
                  @click="resetConfig"
                >
                  Reset Configuration
                </button>
              </div>
            </div>

            <div
              class="setting-card setting-card-danger"
              style="margin-top:20px;"
            >
              <div
                class="setting-row"
                style="flex-direction: column; align-items: flex-start; gap: 10px;"
              >
                <div
                  class="setting-info"
                  style="width:100%;"
                >
                  <TrashIcon
                    class="setting-icon"
                    style="color: #ef4444;"
                  />
                  <div>
                    <span
                      class="setting-name"
                      style="color: #ef4444;"
                    >Delete Account Permanently</span>
                    <span class="setting-desc">Permanently remove your account and all associated applications. This action cannot be reversed.</span>
                  </div>
                </div>
                <button
                  class="btn btn-danger"
                  style="align-self: flex-start; margin-top:10px;"
                  @click="deleteAccount"
                >
                  Erase Data & Account
                </button>
              </div>
            </div>
          </div>
        </section>
      </template>
    </div>
  </main>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import {
  UserIcon, PaintBrushIcon, BellIcon, LockClosedIcon, ShieldCheckIcon, MoonIcon,
  MegaphoneIcon, CheckCircleIcon, ArrowRightStartOnRectangleIcon, BriefcaseIcon,
  InboxIcon, GlobeAltIcon, UserGroupIcon, TrashIcon, EyeIcon, SwatchIcon,
  AdjustmentsHorizontalIcon, CodeBracketIcon
} from '@heroicons/vue/24/outline'

const { user, loading, signOut } = useAuth()
const supabase = useSupabase()

const profile = ref(null)
const activeTab = ref('profile')
const hasChanges = ref(false)

const tabTitle = computed(() => {
  const titles = { profile: 'Identity Base', appearance: 'Visual Output', notifications: 'Alert Matrix', privacy: 'Security Ops', preferences: 'Core Preferences', developer: 'Developer Overrides', account: 'Danger Zone' }
  return titles[activeTab.value]
})

const tabDescription = computed(() => {
  const desc = { profile: 'Manage your platform identity and social connections.', appearance: 'Tweak CSS and zoom rendering metrics.', notifications: 'Configure dozens of granular notification hooks.', privacy: 'Lock down your session trackers and visibility.', preferences: 'Adjust structural defaults.', developer: 'Access raw API and debugging components.', account: 'Destructive session actions.' }
  return desc[activeTab.value]
})

// === MASSIVE SETTINGS OBJECT ===
// Combines ~100 distinct toggles into a reactive blob
const defaultOpts = {
  // Profile
  displayName: '', pronouns: '', statusMsg: '', location: '', robloxUsername: '', website: '', bio: '',
  // Appearance
  theme: 'dark', pureBlack: false, accentColor: '#ef4444', zoom: 100, highContrast: false, dyslexicFont: false, reduceMotion: false, disableBlurs: false, compactMode: false, autoHideSidebar: false,
  // Notifications - Email
  emApply: true, emUpdate: true, emReject: true, emAccept: true, emStaffMsg: true, emNewsletter: false, emSecurity: true, emDigest: false,
  // Notifications - Push
  pushDM: true, pushMention: true, pushUpdate: true, pushError: false,
  // Notifications - Sounds
  soundAlerts: true, soundApp: false, volume: 50, quietHours: false, quietStart: '22:00', quietEnd: '08:00', webhookUrl: '',
  // Privacy
  privOnline: true, privGame: true, privSearch: true, privDM: true, privAnalytics: false, telemetryCrash: false, telemetryUsage: false, strictCookies: false,
  // Prefs
  language: 'en', timezone: 'UTC', dateFormat: 'MM/DD/YYYY', weekStart: 'mon', autoSave: true, autoplay: false, confirmDestructive: true, hideClosed: false, defaultAdminTab: 'applications',
  // Dev
  devMode: false, overrideCSS: false, logNetwork: false, mockBackend: false, hardwareDisable: false, logLevel: 'error'
}

const opts = reactive({ ...defaultOpts })

// Groups for v-for structural rendering
const emailNotifs = {
  emApply: { name: 'App Received', desc: 'Email when an application is sent.' },
  emUpdate: { name: 'App Updates', desc: 'Email when your application status changes.' },
  emReject: { name: 'Rejection Output', desc: 'Email on application failure.' },
  emAccept: { name: 'Acceptance Praise', desc: 'Email on application success.' },
  emStaffMsg: { name: 'Staff Messages', desc: 'Trigger on direct staff notes.' },
  emNewsletter: { name: 'Marketing Newsletter', desc: 'Company digests.' },
  emSecurity: { name: 'Security Alerts', desc: 'Unrecognized IP sign-ins.' },
  emDigest: { name: 'Weekly Digest', desc: 'Rollup of all week activity.' }
}
const pushNotifs = {
  pushDM: { name: 'Direct Messages', desc: 'Desktop native alert.' },
  pushMention: { name: 'Role Mentions', desc: 'When you are @ mentioned.' },
  pushUpdate: { name: 'App Updates', desc: 'Vital system updates.' },
  pushError: { name: 'System Errors', desc: 'Broadcast major downtimes.' }
}
const privacyToggles = {
  privOnline: { name: 'Show Online Status', desc: 'Let others know when you are active.' },
  privGame: { name: 'Show Game Presence', desc: 'Broadcast Roblox presence if linked.' },
  privSearch: { name: 'Index Profile', desc: 'Allow profile to be searched.' },
  privDM: { name: 'Open DMs', desc: 'Allow any staff to DM you instantly.' }
}
const devOverrides = {
  overrideCSS: { name: 'Inject Custom CSS', desc: 'Enables a raw CSS pane (mock)' },
  logNetwork: { name: 'Trace Network', desc: 'Show visual network bar' },
  mockBackend: { name: 'Mock Supabase', desc: 'Bypass live DB for local edits' },
  hardwareDisable: { name: 'Disable HWA', desc: 'Disable hardware acceleration' }
}

const THEME_KEY = 'jetjob-complex-settings'

async function fetchProfileData() {
  if (!user.value) return
  const { data } = await supabase.from('profiles').select('*').eq('id', user.value.id).single()
  if (data) Object.assign(profile.value = data)
}

function loadLocal() {
  const stored = localStorage.getItem(THEME_KEY)
  if (stored) {
    try {
      const parsed = JSON.parse(stored)
      Object.assign(opts, parsed)

      // Apply theme strictly
      document.documentElement.classList.toggle('dark', opts.theme === 'dark')
      document.documentElement.style.setProperty('--red', opts.accentColor)
    } catch (e) {}
  } else {
    opts.theme = window.matchMedia?.('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
    document.documentElement.classList.toggle('dark', opts.theme === 'dark')
  }
}

watch(opts, () => {
  hasChanges.value = true
  localStorage.setItem(THEME_KEY, JSON.stringify(opts))

  // Realtime structural changes
  document.documentElement.classList.toggle('dark', opts.theme === 'dark')
  document.documentElement.style.setProperty('--red', opts.accentColor)
  if (opts.zoom) document.body.style.zoom = (opts.zoom / 100)
}, { deep: true })

async function saveAll() {
  hasChanges.value = false
  // Map core fields to supabase if needed
  if (opts.robloxUsername !== profile.value?.roblox_username) {
    await supabase.from('profiles').update({ roblox_username: opts.robloxUsername }).eq('id', user.value.id)
  }
  const btn = document.querySelector('.unsaved-badge button')
  if (btn) { btn.innerText = 'Saved!'; setTimeout(() => { btn.innerText = 'Save Changes' }, 2000) }
}

function toggleTheme() {
  // Driven automatically by reactive watcher
}

function mockAction(msg) {
  alert(msg)
}

function resetConfig() {
  if (confirm('Confirm reset? This clears all 100 configured tabs.')) {
    Object.assign(opts, defaultOpts)
  }
}

function deleteAccount() {
  if (!confirm('Are you ABSOLUTELY sure you want to delete your account? All applications and data will be removed forever.')) return
  alert('This feature is restricted in the demo environment. Please contact an administrator server owner to delete your account.')
}

async function handleSignOut() {
  await signOut()
}

onMounted(async () => {
  loadLocal()
  await fetchProfileData()
  // Hydrate DB fields back into reactive obj
  if (profile.value) {
    opts.robloxUsername = profile.value.roblox_username || opts.robloxUsername
  }
  // Remove changes triggered by boot
  setTimeout(() => hasChanges.value = false, 100)
})

useSeoMeta({ title: 'Engine Configuration Matrix' })
</script>

<style scoped>
.page { min-height: 100vh; padding-bottom: 64px; background: var(--bg-alt); }
.settings-layout {
  display: grid;
  grid-template-columns: 280px 1fr;
  gap: 40px;
  padding-top: 40px;
  max-width: 1300px;
  margin: 0 auto;
}

/* Sidebar */
.settings-sidebar { display: flex; flex-direction: column; gap: 24px; position: sticky; top: 30px; height: calc(100vh - 60px); }
.sidebar-user { display: flex; align-items: center; gap: 12px; padding-bottom: 24px; border-bottom: 1px solid var(--border); }
.sidebar-avatar { width: 44px; height: 44px; border-radius: 50%; object-fit: cover; border: 2px solid var(--border); }
.sidebar-user-info { display: flex; flex-direction: column; }
.user-fullname { font-size: 0.95rem; font-weight: 800; color: var(--text); }
.user-role { font-size: 0.75rem; color: var(--muted); text-transform: uppercase; font-weight: 700; letter-spacing: 0.05em; }
.user-status-msg { font-size: 0.75rem; color: var(--text); margin-top: 4px; font-style: italic; opacity: 0.8; }

.settings-nav { display: flex; flex-direction: column; gap: 4px; overflow-y: auto; flex:1; }
.nav-item {
  display: flex; align-items: center; gap: 12px; padding: 12px 14px; border-radius: 8px; border: none; background: transparent; color: var(--muted); font-size: 0.95rem; font-weight: 600; cursor: pointer; transition: all 150ms ease; text-align: left;
}
.nav-item:hover { background: var(--surface); color: var(--text); }
.nav-item.active { background: var(--surface); color: var(--red); box-shadow: inset 3px 0 0 var(--red); }
.nav-icon { width: 20px; height: 20px; }
.sidebar-footer { font-size: 0.7rem; color: var(--muted); display: flex; flex-direction: column; gap: 5px; opacity: 0.5; }

/* Content */
.settings-content { background: var(--bg); border: 1px solid var(--border); border-radius: 16px; padding: 40px; min-height: 800px; padding-bottom:100px; }

.content-header { margin-bottom: 32px; padding-bottom: 20px; border-bottom: 1px solid var(--border); display:flex; justify-content:space-between; align-items:center; }
.page-title { font-size: 1.8rem; font-weight: 900; color: var(--text); margin: 0 0 6px; letter-spacing: -0.02em; }
.page-sub { font-size: 0.95rem; color: var(--muted); margin: 0; }

.setting-group-title { font-size: 0.9rem; font-weight: 800; text-transform: uppercase; letter-spacing: 0.05em; color: var(--muted); margin: 40px 0 12px 0; }
.setting-card { background: var(--surface); border: 1px solid var(--border); border-radius: 12px; padding: 24px; margin-bottom: 20px; }
.setting-card-danger { border-color: rgba(239,68,68,0.25); }

.setting-grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }

.setting-row { display: flex; align-items: center; justify-content: space-between; gap: 16px; padding: 12px 0; }
.setting-row + .setting-row { border-top: 1px solid var(--border); }
.setting-info { display: flex; align-items: flex-start; gap: 12px; flex: 1; }
.setting-icon { width: 20px; height: 20px; color: var(--muted); flex-shrink: 0; margin-top: 2px; }
.setting-name { display: block; font-size: 0.95rem; font-weight: 700; color: var(--text); }
.setting-desc { display: block; font-size: 0.85rem; color: var(--subtle); margin-top: 4px; line-height: 1.4; }

.setting-form-group { display: flex; flex-direction: column; gap: 6px; }
.setting-form-group label { font-size: 0.85rem; font-weight: 800; color: var(--text); }
.form-input { padding: 12px 14px; border: 1px solid var(--border); border-radius: 8px; background: var(--bg); color: var(--text); font-size: 0.95rem; outline: none; transition: border-color 0.2s; }
.form-input:focus { border-color: var(--red); }
.form-textarea { padding: 12px 14px; border: 1px solid var(--border); border-radius: 8px; background: var(--bg); color: var(--text); font-size: 0.95rem; outline: none; resize: vertical; min-height:100px; }
.form-textarea:focus { border-color: var(--red); }

.discord-connected-box { background: var(--bg-alt); padding: 14px 16px; border-radius: 8px; border: 1px solid var(--border); display: flex; justify-content: space-between; align-items: center; }

/* Toggles */
.toggle-switch { width: 44px; height: 24px; border-radius: 12px; border: none; background: var(--border); cursor: pointer; position: relative; flex-shrink: 0; transition: background 200ms ease; }
.toggle-switch.active { background: var(--red); }
.toggle-knob { position: absolute; top: 3px; left: 3px; width: 18px; height: 18px; border-radius: 50%; background: #fff; box-shadow: 0 1px 4px rgba(0,0,0,0.15); transition: transform 200ms ease; }
.toggle-switch.active .toggle-knob { transform: translateX(20px); }

.btn { display: inline-flex; align-items: center; gap: 7px; font-size: 0.85rem; font-weight: 700; padding: 10px 18px; border-radius: 8px; border: none; cursor: pointer; transition: all 150ms ease; }
.btn-primary { background: var(--red); color: #fff; }
.btn-primary:hover { opacity: 0.9; }
.btn-outline { background: transparent; border: 1px solid var(--border); color: var(--text); }
.btn-outline:hover { background: var(--surface); }
.btn-danger { background: rgba(239,68,68,0.1); color: #ef4444; border: 1px solid rgba(239,68,68,0.2); }
.btn-danger:hover { background: rgba(239,68,68,0.2); }

.unsaved-badge { animation: popIn 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275); }
@keyframes fade { from{opacity:0;} to{opacity:1;} }
@keyframes popIn { from{transform:scale(0.9); opacity:0;} to{transform:scale(1); opacity:1;} }
.text-red { color: #ef4444!important; }
.text-green { color: #10b981; }

.loading-state { grid-column: 1 / -1; text-align: center; padding: 100px; color: var(--muted); }
.spinner { width: 34px; height: 34px; border: 3px solid var(--border); border-top-color: var(--red); border-radius: 50%; animation: spin 0.7s linear infinite; margin: 0 auto 16px; }
@keyframes spin { to { transform: rotate(360deg); } }

@media (max-width: 900px) {
  .settings-layout { grid-template-columns: 1fr; padding-left: 15px; padding-right: 15px; }
  .settings-sidebar { position:static; height:auto; flex-direction: column; border-bottom: 1px solid var(--border); padding-bottom: 20px; }
  .settings-nav { flex-direction: row; gap: 8px; overflow-x: auto; padding-bottom:10px; }
  .nav-item { white-space: nowrap; }
  .setting-grid-2 { grid-template-columns: 1fr; }
  .settings-content { padding: 20px; }
}
</style>
