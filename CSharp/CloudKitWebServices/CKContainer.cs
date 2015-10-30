using System;

namespace CloudKitWebServices
{
	public struct CKContainer
	{
		public const string CKOwnerDefaultName = "__defaultOwner__";

		public readonly string containerIdentifier;

		public CKContainer()
		{
			throw new NotSupportedException();
		}

		public CKContainer(string containerIdentifier)
		{
			this.containerIdentifier = containerIdentifier;
		}
	}
}

