﻿using System;

namespace CloudKitWebServices
{
	public struct CKRecordID
	{
		public readonly string recordName;
		public readonly CKRecordZoneID zoneID;

		public CKRecordID() {
			this.recordName = Guid.NewGuid ().ToString ();
			this.zoneID = new CKRecordZoneID ();
		}

		public CKRecordID(string recordName, CKRecordZoneID? zoneID = null) {
			this.recordName = recordName;
			this.zoneID = zoneID ?? new CKRecordZoneID ();
		}
	}
}
