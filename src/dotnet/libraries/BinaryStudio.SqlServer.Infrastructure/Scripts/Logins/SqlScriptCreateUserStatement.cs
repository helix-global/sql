using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptCreateUserStatement<T>: SqlScriptDdlStatement<T>
        where T: SqlCreateUserStatement
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptCreateUserStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }