using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptMergeActionClause : SqlScriptCodeObject<SqlMergeActionClause>
        {
        public SqlMergeConditionType MergeConditionType { get {  return Source.MergeConditionType; }}

        #region ctor{IServiceProvider,SqlMergeActionClause}
        public SqlScriptMergeActionClause(IServiceProvider context,SqlMergeActionClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }