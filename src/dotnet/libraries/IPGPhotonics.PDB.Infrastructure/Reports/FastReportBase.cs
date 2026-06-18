using System;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal abstract class FastReportBase : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000101)] public virtual String Name { get; }
        [UsedImplicitly][Field(Order=1000102)] public Int32 ZOrder { get; }
        [UsedImplicitly][Field(Order=1000103)] public Restrictions Restrictions { get; }

        #region M:ToString:String
        public override String ToString()
            {
            return $"{((IFastReportClassObjectLegacy)this).ClassName}:Name={Name}";
            }
        #endregion
        }
    }
