﻿using System;

namespace CloudKitWebServices
{

	public struct CKRecordZoneID
	{
		public readonly string zoneName;
		public readonly string ownerName;

		public CKRecordZoneID() {
			this.zoneName = CKRecordZone.CKRecordZoneDefaultName;
			this.ownerName = CKContainer.CKOwnerDefaultName;
		}

		public CKRecordZoneID(string zoneName = CKRecordZone.CKRecordZoneDefaultName, string ownerName = CKContainer.CKOwnerDefaultName) {
			this.zoneName = zoneName;
			this.ownerName = ownerName;
		}
	}
}

