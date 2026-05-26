using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlMergeSpecification))]
    internal sealed class SqlScriptMergeSpecification : SqlScriptDmlSpecification<SqlMergeSpecification>
        {
        #region ctor{IServiceProvider,SqlMergeSpecification}
        public SqlScriptMergeSpecification(IServiceProvider context,SqlMergeSpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }