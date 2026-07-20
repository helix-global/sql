using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Windows;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    /// <summary>
    /// Base class for text objects such as <see cref="FastReportTextObject"/> and <see cref="FastReportRichObject"/>.
    /// </summary>
    /// <remarks>
    /// This class implements common functionality of the text objects.
    /// </remarks>
    internal abstract class FastReportTextObjectBase : FastReportBreakableComponent
        {
        /// <summary>
        /// Gets the object's text.
        /// </summary>
        [UsedImplicitly][Field(Order=1000501)] public String Text { get; }
        /// <summary>
        /// Gets the symbols that will be used to find expressions in the object's text.
        /// </summary>
        [UsedImplicitly][Field(Order=1000504)] public String Brackets { get; }
        /// <summary>
        /// Gets a value that will be hidden.
        /// </summary>
        [UsedImplicitly][Field(Order=1000506)] public String HideValue { get; }
        /// <summary>
        /// Gets a string that will be displayed instead of a null value.
        /// </summary>
        [UsedImplicitly][Field(Order=1000507)] public String NullValue { get; }
        /// <summary>
        /// Gets padding within the text object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000502,Converter=typeof(FastReportThicknessConverter))][DefaultValue("2,0,2,0")] public virtual Thickness Padding { get; } = new Thickness(2,0,2,0);
        /// <summary>
        /// Gets a value indicating that the object's text may contain expressions.
        /// </summary>
        [UsedImplicitly][Field(Order=1000503)][DefaultValue(true)] public Boolean AllowExpressions { get; } = true;
        /// <summary>
        /// Gets a value indicating that zero values must be hidden.
        /// </summary>
        [UsedImplicitly][Field(Order=1000505)] public Boolean HideZeros { get; }
        /// <summary>
        /// Gets a value that determines how to display duplicate values.
        /// </summary>
        [UsedImplicitly][Field(Order=1000509)] public Duplicates Duplicates { get; }
        /// <summary>
        /// Gets a value that specifies how the report engine processes this text object.
        /// </summary>
        [UsedImplicitly][Field(Order=1000508)] public ProcessAt ProcessAt { get; }
        /// <summary>
        /// Gets the collection of formatters.
        /// </summary>
        [UsedImplicitly][Field(Order=1000510,EmptyIfNull = true)] public IList<FastReportFormatBase> Formats { get; } = new List<FastReportFormatBase>{ new FastReportGeneralFormat() };
        /// <summary>
        /// Gets the formatter that will be used to format data in the Text object.
        /// </summary>
        [UsedImplicitly][Field(Order = 1000511)][DefaultValue("General")] public FastReportFormatBase Format
            {
            get { return Formats.FirstOrDefault(); }
            internal set
                {
                if (value == null) { value = new FastReportGeneralFormat(); }
                if (Formats.Count == 0)
                    {
                    Formats.Add(value);
                    }
                else
                    {
                    Formats[0] = value;
                    }
                }
            }

        #region M:WriteXmlE(ISqlXmlWriter,PropertyDescriptor)
        protected override void WriteXmlA(ISqlXmlWriter writer,PropertyDescriptor descriptor) {
            switch (descriptor.Name) {
                case nameof(Text):
                    {
                    break;
                    }
                default:
                    base.WriteXmlA(writer,descriptor);
                    break;
                }
            }
        #endregion
        #region M:WriteXmlE(ISqlXmlWriter,IList<PropertyDescriptor>)
        protected override void WriteXmlE(ISqlXmlWriter writer,IList<PropertyDescriptor> descriptors) {
            if (!String.IsNullOrEmpty(Text)) {
                using (writer.ElementGroup(URI_FR_PREFIX,$"{((IFastReportClassObject)(this)).ClassName}.Text",URI_FR_NS)) {
                    writer.WriteCData(Text);
                    }
                }
            base.WriteXmlE(writer,descriptors);
            }
        #endregion
        #region M:Serialize(IFastReportSerializer,String,Object)
        public override void Serialize(IFastReportSerializer serializer,String prefix,Object other) {
            if (serializer == null) { throw new ArgumentNullException(nameof(serializer)); }
            serializer.Serialize(this,prefix,other);
            }
        #endregion
        }
    }
