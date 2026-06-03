using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class PageColumns : FastReportObject
        {
        [UsedImplicitly][Field(Order=1000101)][DefaultValue(1)] public Int32 Count { get; } = 1;
        [UsedImplicitly][Field(Order=1000103,Converter=typeof(SqlSingleCollectionConverter))] public IList<Single> Positions { get; }
        [UsedImplicitly][Field(Order=1000102)][DefaultValue(0f)] public Single Width { get; }

        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,this,prefix);
            }
        #endregion
        }
    }