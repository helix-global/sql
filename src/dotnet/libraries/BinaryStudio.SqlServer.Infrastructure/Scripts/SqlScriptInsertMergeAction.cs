using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlInsertMergeAction))]
    internal sealed class SqlScriptInsertMergeAction : SqlScriptMergeAction<SqlInsertMergeAction>
        {
        #region ctor{IServiceProvider,SqlInsertMergeAction}
        public SqlScriptInsertMergeAction(IServiceProvider context,SqlInsertMergeAction source)
            : base(context,source)
            {
            }
        #endregion
        }
    }