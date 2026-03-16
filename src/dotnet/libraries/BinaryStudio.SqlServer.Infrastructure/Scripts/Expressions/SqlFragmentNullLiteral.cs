using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(NullLiteral))]
    internal sealed class SqlFragmentNullLiteral : SqlFragmentLiteral<NullLiteral>
        {
        #region ctor{IServiceProvider,NullLiteral}
        public SqlFragmentNullLiteral(IServiceProvider context,NullLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }