using System;

namespace CloudKitWebServices
{
	public struct CKRecordZone
	{
		public const string CKRecordZoneDefaultName = "_defaultZone";
		public CKRecordZoneID zoneID;

		public CKRecordZone()
		{
			throw new NotSupportedException();
		}

		public CKRecordZone(string zoneName)
		{
			this.zoneID = new CKRecordZoneID(zoneName);
		}

		public CKRecordZone(CKRecordZoneID zoneID)
		{
			this.zoneID = zoneID;
		}

		public static CKRecordZone defaultRecordZone()
		{
			return new CKRecordZone(CKRecordZoneDefaultName);
		}
	}
}

