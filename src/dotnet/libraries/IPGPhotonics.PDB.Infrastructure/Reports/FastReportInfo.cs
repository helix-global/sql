using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReportInfo : FastReportObject,IFastReportClassObject
        {
        [UsedImplicitly][Field(Order=1000102)] public String Author { get; }
        [UsedImplicitly][Field(Order=1000106)] public DateTime Created { get; }
        [UsedImplicitly][Field(Order=1000107)] public DateTime Modified { get; }
        [UsedImplicitly][Field(Order=1000110)] public String CreatorVersion { get; }
        [UsedImplicitly][Field(Order=1000104)] public String Description { get; }
        [UsedImplicitly][Field(Order=1000101)] public String Name { get; }
        [UsedImplicitly][Field(Order=1000103)] public String Version { get; }
        [UsedImplicitly][Field(Order=1000105)] public Byte[] Picture { get; }
        [UsedImplicitly][Field(Order=1000109)][DefaultValue(0.1f)] public Single PreviewPictureRatio { get; } = 0.1f;
        [UsedImplicitly][Field(Order=1000108)] public Boolean SavePreviewPicture { get; }
        String IFastReportClassObject.ClassName { get { return "ReportInfo"; }}

        public override IEnumerable<FastReportObject> Children { get {
            return EmptyArray<FastReportObject>.List;
            }}

        #region M:Serialize(XmlWriter,String,Object)
        public override void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            SerializeAttributes(writer,prefix);
            }
        #endregion
        }
    }
