using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptExecuteAsClause : SqlScriptCodeObject<SqlExecuteAsClause>
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        protected SqlScriptExecuteAsClause(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlExecuteAsClause.ExecuteAsCaller")]
    internal sealed class SqlScriptExecuteAsCaller : SqlScriptExecuteAsClause
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        public SqlScriptExecuteAsCaller(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlExecuteAsClause.ExecuteAsOwner")]
    internal sealed class SqlScriptExecuteAsOwner : SqlScriptExecuteAsClause
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        public SqlScriptExecuteAsOwner(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlExecuteAsClause.ExecuteAsSelf")]
    internal sealed class SqlScriptExecuteAsSelf : SqlScriptExecuteAsClause
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        public SqlScriptExecuteAsSelf(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }

    [SqlScriptObject("Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlExecuteAsClause.ExecuteAsUser")]
    internal sealed class SqlScriptExecuteAsUser : SqlScriptExecuteAsClause
        {
        #region ctor{IServiceProvider,SqlExecuteAsClause}
        public SqlScriptExecuteAsUser(IServiceProvider context,SqlExecuteAsClause source)
            : base(context,source)
            {
            }
        #endregion
        }
    }