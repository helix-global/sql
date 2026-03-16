using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDeleteMergeAction))]
    internal sealed class SqlScriptDeleteMergeAction : SqlScriptMergeAction<SqlDeleteMergeAction>
        {
        #region ctor{IServiceProvider,SqlDeleteMergeAction}
        public SqlScriptDeleteMergeAction(IServiceProvider context,SqlDeleteMergeAction source)
            : base(context,source)
            {
            }
        #endregion
        }
    }