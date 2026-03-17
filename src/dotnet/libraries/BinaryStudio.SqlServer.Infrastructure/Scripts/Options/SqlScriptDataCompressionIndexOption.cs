using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDataCompressionIndexOption))]
    internal sealed class SqlScriptDataCompressionIndexOption : SqlScriptIndexOption<SqlDataCompressionIndexOption>
        {
        [UsedImplicitly][Field] public SqlDataCompressionType CompressionType { get; }
        public override SqlIndexOptionType Type { get { return SqlIndexOptionType.DataCompression; }}

        #region ctor{IServiceProvider,SqlDataCompressionIndexOption}
        public SqlScriptDataCompressionIndexOption(IServiceProvider context,SqlDataCompressionIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }