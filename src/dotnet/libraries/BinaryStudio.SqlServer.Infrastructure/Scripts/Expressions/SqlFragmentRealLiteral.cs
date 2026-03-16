using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(RealLiteral))]
    internal sealed class SqlFragmentRealLiteral : SqlFragmentLiteral<RealLiteral>
        {
        #region ctor{IServiceProvider,RealLiteral}
        public SqlFragmentRealLiteral(IServiceProvider context,RealLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }