using System;
using System.Collections.Generic;

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

		private Dictionary<string, object> fields;

		public CKRecord()
		{
			throw new NotSupportedException();
		}

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

			this.fields = new Dictionary<string, object>();
		}

		public object this [string key] {
			get {
				return fields[key];
			}
			set {
				fields[key] = value;
			}
		}

		public object objectForKey(string key)
		{
			return this[key];
		}

		public void setObject(object obj, string forKey)
		{
			this[forKey] = obj;
		}

		public string[] allKeys()
		{
			return new List<string>(fields.Keys).ToArray();
		}

		/*
		public string[] changedKeys()
		{
			throw new NotImplementedException();
		}
		*/
	}
}

