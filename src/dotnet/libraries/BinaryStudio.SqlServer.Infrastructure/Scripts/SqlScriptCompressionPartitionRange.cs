using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCompressionPartitionRange : SqlScriptCodeObject<SqlCompressionPartitionRange>
        {
        #region ctor{IServiceProvider,SqlCompressionPartitionRange}
        public SqlScriptCompressionPartitionRange(IServiceProvider context,SqlCompressionPartitionRange source)
            : base(context,source)
            {
            }
        #endregion
        }
    }