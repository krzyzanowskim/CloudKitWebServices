using NUnit.Framework;
using System;
using CloudKitWebServices;

namespace CKRecordTests
{
	[TestFixture()]
	public class Test
	{
		[Test()]
		public void CKRecordID()
		{
			CKRecordID recordID = new CKRecordID("name");
			Assert.AreSame(recordID.recordName, "name");
			Assert.AreSame(recordID.zoneID.zoneName, CKRecordZone.CKRecordZoneDefaultName);
			Assert.AreSame(recordID.recordName, "name");
		}

		[Test()]
		public void CKRecordZoneID()
		{
			CKRecordZoneID zoneID = new CKRecordZoneID();
			Assert.AreSame(zoneID.zoneName, CKRecordZone.CKRecordZoneDefaultName);
			Assert.AreSame(zoneID.ownerName, CKContainer.CKOwnerDefaultName);
		}

		[Test()]
		public void CKRecord()
		{
			CKRecord record = new CKRecord("type");
			Assert.AreSame(record.recordType, "type");
			Assert.AreNotSame(record.recordID.recordName, CKContainer.CKOwnerDefaultName);
		}

	
		[Test()]
		public void CKRecordIndexer()
		{
			CKRecord record = new CKRecord("type");
			record["field1"] = "blabla";
			Assert.AreSame(record["field1"], "blabla");
		}

		[Test()]
		public void CKRecordKeys()
		{
			CKRecord record = new CKRecord("type");
			record["field1"] = "blabla1";
			record["field2"] = "blabla2";
			Assert.AreEqual(record.allKeys(), new string[] { "field1", "field2" });
		}
	}
}

