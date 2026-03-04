using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptDataCompressionIndexOption : SqlScriptIndexOption<SqlDataCompressionIndexOption>
        {
        public SqlDataCompressionType CompressionType {get{ return Source.CompressionType; }}

        #region ctor{IServiceProvider,SqlDataCompressionIndexOption}
        public SqlScriptDataCompressionIndexOption(IServiceProvider context,SqlDataCompressionIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }