using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlUpdateMergeAction))]
    internal sealed class SqlScriptUpdateMergeAction : SqlScriptMergeAction<SqlUpdateMergeAction>
        {
        #region ctor{IServiceProvider,SqlUpdateMergeAction}
        public SqlScriptUpdateMergeAction(IServiceProvider context,SqlUpdateMergeAction source)
            : base(context,source)
            {
            }
        #endregion
        }
    }