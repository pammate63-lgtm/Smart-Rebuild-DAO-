# 🏗️ Smart Rebuild DAO

A decentralized autonomous organization for disaster recovery and community rebuilding. Connect communities, coordinate relief efforts, fund reconstruction projects, and build resilient infrastructure through transparent blockchain governance.

## 🌟 Features

- **🤝 Community Membership**: Join the DAO with membership fees and build reputation
- **🚨 Disaster Reporting**: Report and verify disaster events in real-time
- **🏗️ Rebuild Projects**: Create and manage community reconstruction projects
- **💰 Democratic Funding**: Vote on funding proposals for critical projects
- **📊 Progress Tracking**: Monitor project updates and fund utilization
- **🏆 Reputation System**: Reward active contributors and project completions
- **💎 Treasury Management**: Transparent fund pooling and allocation
- **🗳️ Decentralized Governance**: Community-driven decision making

## 🛠️ How It Works

### Community Onboarding
1. **👥 Member Registration**: Pay 50,000 µSTX membership fee to join
2. **📍 Location Setup**: Provide name and location for community mapping
3. **⭐ Reputation Building**: Start with 100 reputation points
4. **🎯 Active Participation**: Engage in voting, reporting, and project management

### Disaster Response Cycle
- **🚨 Report Events**: Members report disasters with severity and impact data
- **✅ Verification Process**: Admin verification for accuracy and authenticity
- **🏗️ Project Creation**: Develop rebuilding projects based on verified reports
- **💰 Funding Proposals**: Submit funding requests for community vote
- **🗳️ Democratic Voting**: 24-hour voting period for all proposals
- **⚡ Execution**: Approved projects receive automatic funding distribution

### Progress & Accountability
- **📈 Real-time Updates**: Project owners provide progress reports
- **💸 Fund Tracking**: Monitor how reconstruction funds are utilized
- **🏁 Completion Rewards**: Reputation bonuses for successful project completion
- **📊 Community Analytics**: Track DAO performance and impact metrics

## 🔧 Contract Functions

### Member Management

#### `register-member`
Join the Smart Rebuild DAO community.
```clarity
(register-member name location)
```
- **name**: Member's name (max 256 chars)
- **location**: Geographic location (max 128 chars)
- **membership-fee**: 50,000 µSTX required
- **initial-reputation**: 100 points

### Disaster Reporting

#### `report-disaster`
Report disaster events requiring community response.
```clarity
(report-disaster location disaster-type severity affected-population estimated-damage description)
```
- **location**: Disaster location (max 128 chars)
- **disaster-type**: Type of disaster (max 64 chars)
- **severity**: Severity level (1-10 scale)
- **affected-population**: Number of people affected
- **estimated-damage**: Damage estimate in µSTX
- **description**: Detailed description (max 512 chars)

#### `verify-disaster-report`
Verify reported disasters (admin only).
```clarity
(verify-disaster-report report-id)
```

### Project Management

#### `create-rebuild-project`
Propose reconstruction projects for community funding.
```clarity
(create-rebuild-project title description category location requested-amount deadline-blocks beneficiaries priority-level)
```
- **title**: Project title (max 256 chars)
- **description**: Project details (max 512 chars)
- **category**: Project category (max 64 chars)
- **location**: Project location (max 128 chars)
- **requested-amount**: Funding needed in µSTX
- **deadline-blocks**: Project timeline in blocks
- **beneficiaries**: Number of people helped
- **priority-level**: Priority rating (1-5 scale)

#### `update-project-progress`
Provide project updates and fund utilization reports.
```clarity
(update-project-progress project-id update-text funding-used)
```

#### `complete-project`
Mark projects as completed (project owner only).
```clarity
(complete-project project-id)
```
- Awards 50 reputation points to project owner

### Democratic Governance

#### `create-funding-proposal`
Submit funding requests for community vote.
```clarity
(create-funding-proposal project-id title description amount-requested)
```
- **project-id**: Associated rebuild project
- **title**: Proposal title (max 256 chars)
- **description**: Funding justification (max 512 chars)
- **amount-requested**: Minimum 100,000 µSTX
- **voting-period**: 1440 blocks (~10 days)

#### `vote-on-proposal`
Vote on active funding proposals (members only).
```clarity
(vote-on-proposal proposal-id vote-for)
```
- **proposal-id**: Proposal to vote on
- **vote-for**: true for yes, false for no
- **one-vote-limit**: One vote per member per proposal

#### `execute-proposal`
Execute approved proposals after voting period ends.
```clarity
(execute-proposal proposal-id)
```
- Automatically transfers funds if approved (yes > no votes)
- Updates project status to "funded"

### Treasury & Contributions

#### `contribute-to-treasury`
Make additional contributions to the DAO treasury.
```clarity
(contribute-to-treasury amount)
```
- Increases member reputation score
- Supports community resilience fund

### Query Functions

#### `get-member`
Retrieve member profile and statistics.

#### `get-project`
Get detailed project information.

#### `get-proposal`
View funding proposal details and voting results.

#### `get-disaster-report`
Access disaster report data.

#### `get-dao-stats`
Get comprehensive DAO metrics and treasury status.

## 🛠️ Usage Examples

### Join the DAO
```bash
clarinet console
(contract-call? .smart-rebuild-dao register-member 
  "Maria Rodriguez" 
  "San Juan, Puerto Rico")
```

### Report a Disaster
```bash
(contract-call? .smart-rebuild-dao report-disaster 
  "Miami, Florida" 
  "Hurricane" 
  u8 
  u50000 
  u10000000 
  "Category 4 hurricane caused widespread flooding and infrastructure damage")
```

### Create Rebuild Project
```bash
(contract-call? .smart-rebuild-dao create-rebuild-project 
  "Community Center Reconstruction" 
  "Rebuild damaged community center to serve as emergency shelter and meeting space" 
  "Infrastructure" 
  "Downtown Miami" 
  u2000000 
  u4320 
  u500 
  u5)
```

### Submit Funding Proposal
```bash
(contract-call? .smart-rebuild-dao create-funding-proposal 
  u1 
  "Phase 1 Funding Request" 
  "Initial funding for foundation and structural repairs" 
  u500000)
```

### Vote on Proposal
```bash
(contract-call? .smart-rebuild-dao vote-on-proposal u1 true)
```

### Execute Approved Proposal
```bash
(contract-call? .smart-rebuild-dao execute-proposal u1)
```

### Check DAO Statistics
```bash
(contract-call? .smart-rebuild-dao get-dao-stats)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet)
- Node.js (for testing)

### Installation
```bash
git clone <repository>
cd Smart-Rebuild-DAO-
clarinet check
```

### Testing
```bash
npm install
npm test
```

## 📖 Contract Details

- **Contract Name**: `smart-rebuild-dao`
- **Network**: Stacks Blockchain
- **Language**: Clarity
- **Lines of Code**: 363
- **Membership Fee**: 50,000 µSTX
- **Min Proposal**: 100,000 µSTX
- **Voting Period**: 1440 blocks (~10 days)
- **Initial Reputation**: 100 points

## 🛡️ Security Features

- ✅ Member verification for all critical functions
- ✅ One-time registration per member
- ✅ Proposal amount validation (min 100,000 µSTX)
- ✅ Voting period enforcement
- ✅ One vote per member per proposal
- ✅ Project ownership validation
- ✅ Admin-only disaster verification
- ✅ Treasury fund protection
- ✅ Reputation-based governance participation

## 💰 Economics & Governance

### Treasury Revenue Sources
1. **Membership Fees**: 50,000 µSTX per new member
2. **Voluntary Contributions**: Additional member donations
3. **Reputation Incentives**: Contributions increase member reputation
4. **Community Growth**: Expanding membership base

### Democratic Decision Making
- **Open Proposals**: Any member can submit funding requests
- **Equal Voting**: One vote per active member
- **Majority Rule**: Proposals pass with yes > no votes
- **Transparent Process**: All votes recorded on blockchain
- **Automatic Execution**: Approved proposals trigger immediate funding

### Reputation System
- **Base Score**: 100 points for new members
- **Contribution Bonus**: Points for treasury contributions (amount/1000)
- **Completion Rewards**: 50 points for completing projects
- **Activity Tracking**: Participation in governance and project management

## 🌍 Disaster Response Use Cases

### Natural Disasters
- **🌪️ Hurricane Recovery**: Rebuild homes, infrastructure, and community centers
- **🔥 Wildfire Restoration**: Reforest areas and rebuild evacuation routes
- **🌊 Flood Mitigation**: Construct drainage systems and elevated structures
- **⛰️ Earthquake Repair**: Strengthen buildings and improve emergency preparedness

### Community Infrastructure
- **🏥 Healthcare Facilities**: Rebuild hospitals and medical centers
- **🏫 Educational Institutions**: Restore schools and learning facilities
- **🏘️ Housing Projects**: Construct affordable and resilient housing
- **🛣️ Transportation**: Repair roads, bridges, and public transit systems

### Economic Recovery
- **🏪 Small Business Support**: Rebuild commercial districts and markets
- **🔧 Job Creation**: Fund reconstruction projects creating local employment
- **📶 Digital Infrastructure**: Restore communications and internet connectivity
- **⚡ Utilities**: Rebuild power grids and water systems

## 📊 Platform Analytics

Track key DAO performance metrics:
- Total registered members and geographic distribution
- Disaster reports submitted and verification rates
- Active reconstruction projects and completion status
- Funding proposals success rates and amounts distributed
- Member reputation scores and participation levels
- Treasury growth and fund allocation patterns
- Community impact measurements and beneficiary counts

## 🌟 Impact & Outcomes

### Community Resilience
- **Rapid Response**: Faster disaster response through decentralized coordination
- **Local Ownership**: Communities control their own rebuilding priorities
- **Transparent Allocation**: Blockchain-verified fund distribution
- **Inclusive Participation**: Every member has a voice in decisions

### Economic Benefits
- **Efficient Funding**: Direct community-to-project funding reduces overhead
- **Local Economy**: Projects create jobs and stimulate local economic activity
- **Risk Mitigation**: Proactive infrastructure improvements reduce future damage
- **Sustainable Development**: Long-term community resilience planning

### Social Impact
- **Community Building**: Shared governance strengthens social bonds
- **Skill Development**: Members gain experience in project management
- **Democratic Participation**: Direct democracy in action
- **Knowledge Sharing**: Best practices spread across communities

## 🚀 Future Enhancements

- **🌐 Multi-chain Support**: Expand to other blockchain networks
- **📱 Mobile App**: Smartphone interface for easier community access
- **🤖 AI Integration**: Automated disaster detection and response prioritization
- **📊 Advanced Analytics**: ML-powered impact prediction and optimization
- **🌍 Global Network**: Connect DAOs worldwide for large-scale disaster response
- **💡 IoT Sensors**: Real-time disaster monitoring and automated reporting
- **🔗 Partnership API**: Integration with NGOs and government agencies

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `clarinet check`
5. Submit a pull request

## 📄 License

This project is open source. See LICENSE file for details.

## 🆘 Support

For questions or emergency assistance:
- Create an issue on GitHub
- Join our community Discord
- Contact the DAO governance team
- Emergency hotline (for active disasters)

---

*Building resilient communities through decentralized cooperation* 🏗️🤝
