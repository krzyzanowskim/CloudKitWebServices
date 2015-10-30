using System;

namespace CloudKitWebServices
{
	public struct CKRecord
	{
		public readonly CKRecordID recordID;
		public readonly string recordType;

		public readonly DateTime? creationDate;
		public readonly CKRecordID? creatorUserRecordID;
		public readonly DateTime? modificationDate;
		public readonly CKRecordID? lastModifiedUserRecordID;
		public readonly string recordChangeTag;

		public CKRecord(string recordType) : this(recordType, new CKRecordID(Guid.NewGuid().ToString()))
		{
		}

		public CKRecord(string recordType, CKRecordZoneID zoneID) : this(recordType, new CKRecordID(Guid.NewGuid().ToString(), zoneID))
		{
		}

		public CKRecord(string recordType, CKRecordID recordID)
		{
			this.recordType = recordType;
			this.recordID = recordID;
			this.creationDate = null;
			this.creatorUserRecordID = null;
			this.modificationDate = null;
			this.lastModifiedUserRecordID = null;
			this.recordChangeTag = null;
		}
	}
}

