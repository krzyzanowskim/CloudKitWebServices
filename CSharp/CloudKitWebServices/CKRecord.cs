using System;
namespace CloudKitWebServices
{
	public struct CKRecord
	{
		public readonly CKRecordID recordID;
		public readonly string recordType;

		public CKRecord(string recordType) {
			this.recordType = recordType;
			this.recordID = new CKRecordID (Guid.NewGuid().ToString());
		}

		public CKRecord(string recordType, CKRecordZoneID zoneID) {
			this.recordType = recordType;
			this.recordID = new CKRecordID (Guid.NewGuid().ToString(), zoneID);
		}

		public CKRecord(string recordType, CKRecordID recordID) {
			this.recordType = recordType;
			this.recordID = recordID;
		}

	}
}

