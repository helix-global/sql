using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptCreateTypeStatement<T> : SqlScriptDdlStatement<T>
        where T: SqlCreateTypeStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateTypeStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }